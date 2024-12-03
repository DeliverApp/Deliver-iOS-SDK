//
//  BuildAPI.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 25/11/2024.
//

import Foundation

/// A class responsible for interacting with build-related API endpoints.
/// Provides methods to fetch the current build details and to perform actions related to build testing.
internal class BuildAPI {
    
    /// The API model for handling current build-related data.
    enum CurrentBuild {
        
        /// The request structure for fetching the current build.
        /// Includes the `appId` and `buildNumber` as parameters for the API request.
        internal struct Request: Codable {
            var appId: String
            var buildNumber: String
        }
        
        /// The response structure for the current build request.
        /// Contains the `Build` object representing the fetched build details.
        internal struct Response: Codable {
            var build: Build
        }
    }
    
    /// Fetches the current build details based on the app's key and build number.
    ///
    /// This method sends a POST request to the `/build/findOne` endpoint to retrieve the build details.
    /// It requires a valid access token, the app's key, and the current build number.
    ///
    /// - Returns: A `Build` object representing the current build, or `nil` if any required information is missing.
    /// - Throws:
    ///   - `DeliverError.authenticationRequired` if the access token is not available.
    ///   - Network or other API-related errors if the request fails.
    func current() async throws -> Build? {
        guard let accessToken = Context.shared.acccessToken else { throw DeliverError.authenticationRequired }
        guard Context.shared.key.isEmpty == false else { return nil }
        guard let buildNumber = Context.shared.buildNumber else { return nil }
        
        var request = URLRequest(url: URL(string: "\(Context.shared.apiBaseUrl)/build/findOne")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let param = CurrentBuild.Request(appId: Context.shared.key, buildNumber: buildNumber)
        request.httpBody = try? JSONEncoder().encode(param)
        let build: Build = try await URLSession.shared.perform(request)
        return build
    }
    
    /// API model for handling testing-related data.
    enum Testing {
        
        /// The response structure for the testing endpoint, representing a void response.
        internal struct VoidResponse: Codable {}
    }
    
    /// Performs a testing action on a specific build by its ID.
    ///
    /// This method sends a POST request to the `/build/{buildId}/tester` endpoint, which triggers a testing action for the specified build.
    /// It requires a valid access token, the app's key, and the current build number.
    ///
    /// - Parameter buildId: The ID of the build to perform the testing action on.
    /// - Throws:
    ///   - `DeliverError.authenticationRequired` if the access token is not available.
    ///   - Network or other API-related errors if the request fails.
    func testing(buildId: String) async throws -> Void {
        guard let accessToken = Context.shared.acccessToken else { throw DeliverError.authenticationRequired }
        guard Context.shared.key.isEmpty == false else { return }
        guard let buildNumber = Context.shared.buildNumber else { return }
        
        var request = URLRequest(url: URL(string: "\(Context.shared.apiBaseUrl)/build/\(buildId)/tester")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let param = CurrentBuild.Request(appId: Context.shared.key, buildNumber: buildNumber)
        request.httpBody = try? JSONEncoder().encode(param)
        let _: Testing.VoidResponse = try await URLSession.shared.perform(request)
    }
}
