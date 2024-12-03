//
//  ErrorView.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 24/11/2024.
//

import SwiftUI

internal struct ErrorView: View {
    
    var error: Error?
    
    init(_ error: Error? = nil) {
        self.error = error
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Error")
                    .font(.deliver(ofSize: 20, weight: .heavy))
                    .foregroundColor(.red)
                
                // Check if the error is of type DeliverError
                if let DeliverError = error as? DeliverError {
                    switch DeliverError {
                        case .DeliverError(let originalError,
                                           let request,
                                           let response,
                                           let statusCode,
                                           let headers,
                                           let data):
                            
                            VStack(alignment: .leading) {
                                
                                ErrorItem(title: "Original Error", content: originalError.localizedDescription)
                                
                                if let requestURL = request?.url?.absoluteString {
                                    ErrorItem(title: "Request URL:", content: requestURL)
                                } else {
                                    ErrorItem(title: "Request URL:", content: "No URL")
                                }
                                
                                if let allHTTPHeaderFields = request?.allHTTPHeaderFields {
                                    ErrorItem(title: "Request Headers:", content: allHTTPHeaderFields.compactMap({ "\($0.key): \($0.value)"}).joined(separator: "\n") )
                                } else {
                                    ErrorItem(title: "Response:", content: "No headers")
                                }
                                
                                if let response = response {
                                    ErrorItem(title: "Response:", content: response.description)
                                } else {
                                    ErrorItem(title: "Response:", content: "No response")
                                }
                                
                                
                                ErrorItem(title: "Status Code:", content: "\(statusCode ?? -1)")
                                
                                if let headers = headers {
                                    ErrorItem(title: "Headers:", content: headers.map({ "\($0.key): \($0.value)"}).joined(separator: "\n") )
                                } else {
                                    ErrorItem(title: "Headers:", content: "No Headers")
                                }
                                
                                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                    ErrorItem(title: "Data:", content: dataString)
                                } else {
                                    ErrorItem(title: "Data:", content: "No data")
                                }
                            }
                            
                        case .authenticationRequired:
                            // redirect to auth
                            EmptyView()
                                .onAppear {
                                    NotificationCenter.default.post(name: .authenticationRequired, object: nil)
                                }
                    }
                }
                else {
                    // Handle other errors if not a DeliverError
                    VStack {
                        ErrorItem(title: "Localized description:", content: error?.localizedDescription ?? "Unknown error")
                    }
                }
                
                // "Contact US" section
                Text("Contact Us")
                    .font(.deliver(ofSize: 18, weight: .bold))
                    .padding(.top, 20)
            }
            .padding()
        }
    }
}


internal struct ErrorItem: View {
    
    var title: String
    var content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
            Text(content)
                .font(.caption)
            Divider()
        }
        .padding(.top, 10)
    }
}
