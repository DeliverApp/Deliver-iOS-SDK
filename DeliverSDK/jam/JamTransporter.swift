//
//  JamTransporter.swift
//  Atlantis
//
//  Created by Benjamin FROLICHER on 21/11/2023.
//

import UIKit
import Foundation
import Network
import Combine

internal class JamTransporter: Transporter {
  
    // Maximum package size. If package size is bigger than this value, data will be truncate
    static let MaximumSizePackage = 10_485_760 // 10Mb
                     
    // Queue on wich all data will be send to deliver API
    private let queue = DispatchQueue(label: "com.deliver.jam.network") // Serial on purpose
    
    // Package to send when device will be authorized
    private var pendingPackages: [Message] = []
    
    // The maximum number of pending item to prevent Jam consumes too much RAM
    private let maxPendingItem = 50
    
    private var timer: Timer?
    
    private var requestInProgress = false
    
    private var bag = Set<AnyCancellable>()
    private var isAlreadyActive = false
    
    internal init() {
        initNotification()
        
        Context.shared.$isLogActive.sink { [weak self] active in
            guard let self = self else { return }
            if active && self.isAlreadyActive == false {
                isAlreadyActive = true
            }
            else if active == false && isAlreadyActive == true {
                isAlreadyActive = false
            }
        }.store(in: &bag)
    }
    
    /// Start sending request
    func start(_ config: JamConfiguration) {
        // observe configuration here and start timer
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            queue.async {
                // Send to all connections
                self.streamToConnection()
            }
        })
    }
    
    /// Stop sending data to deliver.
    func stop() {
        pendingPackages.removeAll()
        timer?.invalidate()
    }
    
    func send(package: Message) {
        if let m = package as? Message,
            m.content?.request.url.contains("bfrolicher") == false,
            m.content?.request.url.contains("deliver") == false {
            self.pendingPackages.append(package)
        }
    }

    private func streamToConnection() {
        guard isAlreadyActive && requestInProgress == false else {  return }
        guard let buildId = Context.shared.build?.id else { return }

        queue.async { [weak self] in
            Task {
                guard let self = self else { return }
                let packages = self.pendingPackages
                // Compress data by gzip
                let compressedData = packages.compactMap({ $0.content?.toRequestDTO() })
                /// Call deliver API
                
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try? encoder.encode(compressedData)
                
                var request = URLRequest(url: URL(string: "\(Context.shared.apiBaseUrl)/live/requests/\(buildId)/\(Context.shared.sessionId)")!)
                request.httpMethod = "POST"
                request.addValue("application/json",forHTTPHeaderField: "Content-Type")
                request.addValue("application/json",forHTTPHeaderField: "Accept")
                request.httpBody = data
                self.requestInProgress = true
                _ = try await URLSession.shared.data(for: request)
                self.pendingPackages.removeAll()
                self.requestInProgress = false
            }
        }
    }
}

struct RequestDTO: Codable {
    let deviceId: String
    let url: String
    let method: String
    let code: Int
    let duration: Int
    let requestSize: Int
    let responseSize: Int
    let requestHeaders: [String]
    let responseHeaders: [String]
    let requestQuery: [String]
    let requestBody: String
    let responseBody: String
}


extension TrafficPackage {
    func toRequestDTO() -> RequestDTO {
        return RequestDTO(
            deviceId: id,
            url: request.url,
            method: request.method,
            code: response?.statusCode ?? 0, // Default to 0 if no response
            duration: Int(duration * 1000), // Convert to milliseconds
            requestSize: request.body?.count ?? 0,
            responseSize: responseBodyData.count,
            requestHeaders: request.headers.map { "\($0.key): \($0.value)" },
            responseHeaders: response?.headers.map { "\($0.key): \($0.value)" } ?? [],
            requestQuery: URLComponents(string: request.url)?.queryItems?.map { "\($0.name)=\($0.value ?? "")" } ?? [],
            requestBody: request.body.flatMap { String(data: $0, encoding: .utf8) } ?? "",
            responseBody: String(data: responseBodyData, encoding: .utf8) ?? ""
        )
    }
}


extension JamTransporter {
    
    private func initNotification() {
        // Memory Warning notification is only available on iOS
        NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil,
                                               queue: nil) { [weak self] _ in
            self?.queue.async {
                self?.pendingPackages.removeAll()
            }
        }
    }
}

