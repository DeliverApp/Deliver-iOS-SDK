//
//  DeliverError.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 23/11/2024.
//

import Foundation


enum DeliverError: Error {
    case authenticationRequired
    case DeliverError(originalError: Error, request: URLRequest?, response: URLResponse?, statusCode: Int?, headers: [String: String]?, data: Data?)
}
