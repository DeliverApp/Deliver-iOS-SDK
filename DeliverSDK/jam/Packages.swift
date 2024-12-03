//
//  Packages.swift
//  atlantis
//
//  Created by Nghia Tran on 10/23/20.
//  Copyright © 2020 Proxyman. All rights reserved.
//

import Foundation

import UIKit

internal final class TrafficPackage: Codable, CustomDebugStringConvertible, Serializable {

    internal enum PackageType: String, Codable {
        case http
        case websocket
    }

    // Should not change the variable names
    // since we're using Codable in the main app and Atlantis

    internal let id: String
    internal let startAt: TimeInterval
    internal let request: JamRequest
    internal private(set) var response: JamResponse?
    internal private(set) var error: CustomError?
    internal private(set) var responseBodyData: Data
    internal private(set) var endAt: TimeInterval?
    internal var duration: TimeInterval {
        var duration = 0.0
        if let endAt = self.endAt {
            duration = endAt - self.startAt
        }
        return duration
    }
    internal private(set) var lastData: Data?
    internal let packageType: PackageType
    private(set) var websocketMessagePackage: WebsocketMessagePackage?

    // MARK: - Variables

    private var isLargeReponseBody: Bool {
        if responseBodyData.count > JamTransporter.MaximumSizePackage {
            return true
        }
        return false
    }

    private var isLargeRequestBody: Bool {
        if let requestBody = request.body, requestBody.count > JamTransporter.MaximumSizePackage {
            return true
        }
        return false
    }

    // MARK: - Init

    init(id: String,
         request: JamRequest,
         response: JamResponse? = nil,
         responseBodyData: Data? = nil,
         packageType: PackageType = .http,
         startAt: TimeInterval = Date().timeIntervalSince1970,
         endAt: TimeInterval? = nil) {
        self.id = id
        self.request = request
        self.response = nil
        self.startAt = startAt
        self.endAt = endAt
        self.response = response
        self.responseBodyData = responseBodyData ?? Data()
        self.packageType = packageType
    }

    // MARK: - Builder

    static func buildRequest(sessionTask: URLSessionTask, id: String) -> TrafficPackage? {
        guard let currentRequest = sessionTask.currentRequest,
            let request = JamRequest(currentRequest) else { return nil }

        // Check if it's a websocket
        if let websocketClass = NSClassFromString("__NSURLSessionWebSocketTask"),
           sessionTask.isKind(of: websocketClass) {
            return TrafficPackage(id: id, request: request, packageType: .websocket)
        }

        // Or normal websocket
        return TrafficPackage(id: id, request: request)
    }

    static func buildRequest(request: NSURLRequest, id: String) -> TrafficPackage? {
        guard let request = JamRequest(request as URLRequest) else { return nil }
        return TrafficPackage(id: id, request: request)
    }

    static func buildRequest(urlRequest: URLRequest, urlResponse: URLResponse, bodyData: Data?) -> TrafficPackage? {
        guard let request = JamRequest(urlRequest) else { return nil }
        let response = JamResponse(urlResponse)
        return TrafficPackage(id: UUID().uuidString, request: request, response: response, responseBodyData: bodyData)
    }

    static func buildRequest(urlRequest: URLRequest, error: Error) -> TrafficPackage? {
        guard let request = JamRequest(urlRequest) else { return nil }
        let package = TrafficPackage(id: UUID().uuidString, request: request)
        package.updateDidComplete(error)
        return package
    }

    // MARK: - Internal func

    func updateResponse(_ response: URLResponse) {
        // Construct the Response without body
        self.response = JamResponse(response)
    }
    
    func updateDidComplete(_ error: Error?) {
        endAt = Date().timeIntervalSince1970
        if let error = error {
            self.error = CustomError(error)
        }
    }

    func appendRequestData(_ data: Data) {
        // This func should be called in Upload Tasks
        request.appendBody(data)
    }

    func appendResponseData(_ data: Data) {

        // A dirty solution to prevent this method call twice from Method Swizzler
        // It only occurs if it's a LocalDownloadTask
        // LocalDownloadTask call it delegate, so the swap method is called twiced
        //
        // TODO: Inspired from Flex
        // https://github.com/FLEXTool/FLEX/blob/e89fec4b2d7f081aa74067a86811ca115cde280b/Classes/Network/PonyDebugger/FLEXNetworkObserver.m#L133

        // Skip if the same data (same pointer) is called twice
        if let lastData = lastData, data == lastData {
            return
        }
        lastData = data
        responseBodyData.append(data)
    }

    func toData() -> Data? {
        // Set nil to prevent being encode to JSON
        // It might increase the size of the message
        lastData = nil

        // For some reason, JSONEncoder could not allocate enough RAM to encode a large body
        // It crashes the app if the body might be > 100Mb
        // We decice to skip the body, but send the request/response
        // https://github.com/ProxymanApp/atlantis/issues/57
        if isLargeReponseBody {
            self.responseBodyData = "<Skip Large Body>".data(using: String.Encoding.utf8)!
        }
        if isLargeRequestBody {
            self.request.resetBody()
        }

        // Encode to JSON
        do {
            return try JSONEncoder().encode(self)
        } catch let error {
            print("[DeliverJam][Error] Can't serialize request with error \(error)")
        }
        return nil
    }

    internal var debugDescription: String {
        return "Package: id=\(id), request=\(String(describing: request)), response=\(String(describing: response))"
    }

    func setWebsocketMessagePackage(package: WebsocketMessagePackage) {
        self.websocketMessagePackage = package
    }
}

struct JamDevice: Codable {

    var name: String
    let model: String

    static let current = JamDevice()

    init() {
        #if os(OSX)
        let macName = Host.current().name ?? "Unknown Mac Devices"
        name = macName
        model = "\(macName) \(ProcessInfo.processInfo.operatingSystemVersionString)"
        #elseif os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
        let device = UIDevice.current
        name = device.name
        model = "\(device.name) (\(device.systemName) \(device.systemVersion))"
        #endif
    }
}

struct Project: Codable {

    static let current = Project()

    var name: String
    let bundleIdentifier: String

    init() {
        name = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Untitled"
        bundleIdentifier = Bundle.main.bundleIdentifier ?? "No bundle identifier"
    }
}

internal struct Header: Codable {

    internal let key: String
    internal let value: String

    internal init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

internal final class JamRequest: Codable {

    // MARK: - Variables

    internal let url: String
    internal let method: String
    internal let headers: [Header]
    internal private(set) var body: Data?

    // MARK: - Init

    internal init(url: String, method: String, headers: [Header], body: Data?) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }

    init?(_ urlRequest: URLRequest?) {
        guard let urlRequest = urlRequest else { return nil }
        url = urlRequest.url?.absoluteString ?? "-"
        method = urlRequest.httpMethod ?? "-"
        headers = urlRequest.allHTTPHeaderFields?.map { Header(key: $0.key, value: $0.value ) } ?? []
        body = urlRequest.httpBody
    }

    func appendBody(_ data: Data) {
        if self.body == nil {
            self.body = Data()
        }
        self.body?.append(data)
    }

    func resetBody() {
        self.body = nil
    }
}

internal struct JamResponse: Codable {

    // MARK: - Variables

    let statusCode: Int
    let headers: [Header]

    // MARK: - Init

    init(statusCode: Int, headers: [Header]) {
        self.statusCode = statusCode
        self.headers = headers
    }

    init?(_ response: URLResponse) {
        if let httpResponse = response as? HTTPURLResponse {
            statusCode = httpResponse.statusCode
            headers = httpResponse.allHeaderFields.map { Header(key: $0.key as? String ?? "Unknown Key", value: $0.value as? String ?? "Unknown Value" ) }
        } else {
            statusCode = 200
            headers = [Header(key: "Content-Length", value: "\(response.expectedContentLength)"),
                       Header(key: "Content-Type", value: response.mimeType ?? "plain/text")]
        }
    }
}

internal struct CustomError: Codable {

    internal let code: Int
    internal let message: String

    init(_ error: Error) {
        let nsError = error as NSError
        self.code = nsError.code
        self.message = nsError.localizedDescription
    }

    init(_ error: NSError) {
        self.code = error.code
        self.message = error.localizedDescription
    }
}

internal struct WebsocketMessagePackage: Codable, Serializable {

    internal enum MessageType: String, Codable {
        case pingPong
        case send
        case receive
        case sendCloseMessage
    }

    internal enum Message {
        case data(Data)
        case string(String)

        init?(message: URLSessionWebSocketTask.Message) {
            switch message {
            case .data(let data):
                self = .data(data)
            case .string(let str):
                self = .string(str)
            @unknown default:
                return nil
            }
        }
    }

    private let id: String
    private let createdAt: TimeInterval
    private let messageType: MessageType
    private let stringValue: String?
    private let dataValue: Data?

    init(id: String, message: Message, messageType: MessageType) {
        self.messageType = messageType
        self.id = id
        self.createdAt = Date().timeIntervalSince1970
        switch message {
        case .data(let data):
            self.dataValue = data
            self.stringValue = nil
        case .string(let strValue):
            self.stringValue = strValue
            self.dataValue = nil
        }
    }

    init(id: String, closeCode: Int, reason: Data?) {
        self.messageType = .sendCloseMessage
        self.id = id
        self.createdAt = Date().timeIntervalSince1970
        self.stringValue = "\(closeCode)" // Temporarily store the closeCode by String
        self.dataValue = reason
    }

    func toData() -> Data? {
        // Encode to JSON
        do {
            return try JSONEncoder().encode(self)
        } catch let error {
            print("[DeliverJam][Error] Can't serialize request with error \(error)")
        }
        return nil
    }
}

extension UIImage {

    static var appIcon: UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else { return nil }
        return UIImage(named: lastIcon)

    }

    func getPNGData() -> Data? {
        return self.pngData()
    }
}
