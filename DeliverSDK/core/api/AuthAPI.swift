//
//  AuthAPI.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 23/11/2024.
//

import Foundation

///
internal class AuthAPI {
    
    /// Data struct
    enum AuthSecurityCode {
        internal struct Request: Codable {
            var email: String
            var securityCode: String
        }
        
        internal struct Response: Codable {
            var token: String
        }
    }
    
    /// Signs in a user using an email and a one-time password (OTP).
    /// This asynchronous function communicates with the authentication system
    /// to verify the provided credentials and return a response.
    ///
    /// - Parameters:
    ///   - email: The email address of the user attempting to sign in.
    ///   - otp: The one-time password sent to the user's email or device.
    ///
    /// - Returns: A `String?` representing a session token or identifier if the sign-in is successful.
    ///           Returns `nil` if the sign-in fails or the credentials are incorrect.
    ///
    /// - Throws: This function can throw errors during the sign-in process.
    ///           Errors can include network issues, invalid credentials, or server errors.
    func signIn(email: String, otp: String) async throws -> String? {
        var request = URLRequest(url: URL(string: "\(Context.shared.apiBaseUrl)/auth/securitycode")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let param = AuthSecurityCode.Request(email: email, securityCode: otp)
        request.httpBody = try? JSONEncoder().encode(param)
        let response: AuthSecurityCode.Response = try await URLSession.shared.perform(request)
        return response.token
    }
}
