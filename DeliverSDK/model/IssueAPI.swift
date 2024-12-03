//
//  IssueAPI.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 26/11/2024.
//

import Foundation

/// A class responsible for interacting with the issue reporting API.
/// Provides methods to create and report issues related to builds.
internal class IssueAPI {
    
    /// API model for creating an issue.
    enum CreateIssue {
        
        /// The response structure for creating an issue.
        /// Represents a void response since no data is returned after the issue is created.
        internal struct VoidResponse: Codable {}
    }
    
    /// Reports an issue with the given details and optional file attachment.
    ///
    /// This method sends a POST request to the `/build/{buildId}/issue/create` endpoint with the issue details and optional file attached.
    /// It creates a multipart form-data body for the request that includes the issue information (`title`, `description`, and `criticality`),
    /// as well as an optional file if provided.
    ///
    /// - Parameters:
    ///   - issue: The `CreateIssueDTO` object containing the issue details (`title`, `description`, and `criticality`).
    ///   - fileURL: An optional URL pointing to the file to attach to the issue (e.g., screenshot or log file).
    /// - Throws:
    ///   - `DeliverError.authenticationRequired` if the access token is missing.
    ///   - `DeliverError.invalidKey` if the app's key is missing.
    ///   - `DeliverError.buildNotFound` if the build ID is missing.
    ///   - Network or other API-related errors if the request fails.
    func report(issue: CreateIssueDTO, fileURL: URL?) async throws -> Void {
        guard let accessToken = Context.shared.acccessToken else { throw DeliverError.authenticationRequired }
        guard Context.shared.key.isEmpty == false else { return }
        guard let buildId = Context.shared.build?.id else { return }
        
        var request = URLRequest(url: URL(string: "\(Context.shared.apiBaseUrl)/build/\(buildId)/issue/create")!)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Create multipart body
        let body = try createMultipartBody(boundary: boundary, issue: issue, fileURL: fileURL)
        request.httpBody = body
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        
        let _: CreateIssue.VoidResponse = try await URLSession.shared.perform(request)
    }
    
    /// Creates a multipart form-data body for the issue report request.
    ///
    /// This helper method generates the body of the request, including the issue's title, description, and criticality.
    /// If a file URL is provided, it adds the file to the body of the request.
    ///
    /// - Parameters:
    ///   - boundary: The unique boundary string that separates different parts of the multipart form-data body.
    ///   - issue: The `CreateIssueDTO` object containing the issue details (`title`, `description`, and `criticality`).
    ///   - fileURL: An optional URL pointing to the file to be included in the request (e.g., a screenshot).
    /// - Returns: The generated `Data` object representing the multipart body.
    /// - Throws:
    ///   - Errors related to reading the file at the specified `fileURL` if the file cannot be loaded.
    func createMultipartBody(
        boundary: String,
        issue: CreateIssueDTO,
        fileURL: URL?
    ) throws -> Data {
        var body = Data()
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"title\"\r\n\r\n")
        body.append("\(issue.title)\r\n")
        
        if let description = issue.description {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n")
            body.append("\(description)\r\n")
        }
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"criticality\"\r\n\r\n")
        body.append("\(issue.criticality)\r\n")
        
        if let fileURL = fileURL {
            // Add file
            let fileData = try Data(contentsOf: fileURL)
            let fileName = fileURL.lastPathComponent
            let mimeType = "application/octet-stream" // Change if you know the file type
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"screenshots\"; filename=\"\(fileName)\"\r\n")
            body.append("Content-Type: \(mimeType)\r\n\r\n")
            body.append(fileData)
            body.append("\r\n")
        }
        // End boundary
        body.append("--\(boundary)--\r\n")
        
        return body
    }
    
    
    /// A data transfer object (DTO) used to create an issue report.
    /// Contains the details of the issue, such as its title, description, and criticality.
    struct CreateIssueDTO {
        let title: String
        let description: String?
        let criticality: String
    }
}

fileprivate extension Data {
    /// Appends a string to the `Data` object.
    ///
    /// - Parameter string: The string to append to the `Data` object.
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

