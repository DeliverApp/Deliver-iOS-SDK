//
//  UserAPI.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 25/11/2024.
//

import Foundation


/// A class responsible for interacting with the user-related API endpoints.
/// Provides methods to fetch details about the current authenticated user and other users by ID.
internal class UserAPI {
    
    /// Fetches the details of the currently authenticated user.
    ///
    /// This method sends a request to the `/users/me` endpoint and returns a `User` object with the user's details.
    /// The request requires a valid access token in the `Authorization` header.
    ///
    /// - Returns: A `User` object representing the authenticated user.
    /// - Throws:
    ///   - `DeliverError.authenticationRequired` if no access token is available in the context.
    ///   - Network or other API-related errors if the request fails.
    ///
    func me() async throws -> User {
        guard let accessToken = Context.shared.acccessToken else { throw DeliverError.authenticationRequired }
        var request = URLRequest(url: URL(string: "\(Context.shared.apiBaseUrl)/users/me")!)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return try await URLSession.shared.perform(request)
    }
    
    /// Fetches the details of a user by their unique ID.
    ///
    /// This method sends a request to the `/users/{id}` endpoint, where `{id}` is the user's unique ID,
    /// and returns a `User` object with the requested user's details.
    /// The request requires a valid access token in the `Authorization` header.
    ///
    /// - Parameter id: The unique identifier of the user whose details are to be fetched.
    /// - Returns: A `User` object representing the user with the specified ID.
    /// - Throws:
    ///   - `DeliverError.authenticationRequired` if no access token is available in the context.
    ///   - Network or other API-related errors if the request fails.
    func user(id: String) async throws -> User {
        guard let accessToken = Context.shared.acccessToken else { throw DeliverError.authenticationRequired }
        var request = URLRequest(url: URL(string: "\(Context.shared.apiBaseUrl)/users/\(id)")!)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return try await URLSession.shared.perform(request)
    }
}
