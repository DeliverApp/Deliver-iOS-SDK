//
//  URLRequest+Deliver.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 24/11/2024.
//

import Foundation

internal extension URLSession {
    
    /// Performs a network request asynchronously and decodes the response into the specified output type.
    /// This function sends the given `URLRequest` and returns the decoded result based on the expected `Output` type.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` object that contains the details of the network request, such as the URL, HTTP method, and headers.
    ///
    /// - Returns: A decoded `Output` object, which conforms to the `Codable` protocol, representing the successful result of the request.
    ///
    /// - Throws: `DeliverError`
    ///
    /// Example usage:
    /// ```swift
    /// struct MyResponse: Codable {
    ///     let success: Bool
    ///     let message: String
    /// }
    ///
    /// do {
    ///     let request = URLRequest(url: URL(string: "https://api.example.com/endpoint")!)
    ///     let response: MyResponse = try await perform(request)
    ///     print("Response: \(response.message)")
    /// } catch {
    ///     print("Request failed with error: \(error)")
    /// }
    /// ```
    func perform<Output: Codable>(_ request: URLRequest) async throws -> Output {
                
        var observedResponse:URLResponse?
        var observedData: Data?
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            observedResponse = response
            observedData = data
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DeliverError.DeliverError(
                    originalError: NSError(domain: "Invalid Response", code: 0, userInfo: nil),
                    request: request,
                    response: response,
                    statusCode: nil,
                    headers: nil,
                    data: data
                )
            }
            
            if httpResponse.statusCode == 401 {
                throw DeliverError.authenticationRequired
            }
            
//            if data.isEmpty {
//                throw DeliverError.DeliverError(
//                    originalError: NSError(domain: "No Internet", code: -1009, userInfo: nil),
//                    request: request,
//                    response: response,
//                    statusCode: nil,
//                    headers: nil,
//                    data: nil
//                )
//            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                throw DeliverError.DeliverError(
                    originalError: NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: nil),
                    request: request,
                    response: response,
                    statusCode: httpResponse.statusCode,
                    headers: httpResponse.allHeaderFields as? [String: String],
                    data: data
                )
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.ios8601Prisma)
            let output = try decoder.decode(Output.self, from: data)
            return output
        }
        catch(let error) {
            // Catch and rethrow the error, wrapping it in a single generic DeliverError
            if let urlError = error as? URLError {
                throw DeliverError.DeliverError(
                    originalError: urlError,
                    request: request,
                    response: observedResponse,
                    statusCode: nil,
                    headers: nil,
                    data: observedData
                )
            } else if let decodingError = error as? DecodingError {
                throw DeliverError.DeliverError(
                    originalError: decodingError,
                    request: request,
                    response: observedResponse,
                    statusCode: nil,
                    headers: nil,
                    data: observedData
                )
            } else {
                throw error
            }
        }
    }
}

