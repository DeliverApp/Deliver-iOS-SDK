//
//  Company.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 30/12/2023.
//

import Foundation

internal struct Company: Codable {
    
    var id: String
    var name: String
    var icon: String?
    var email: String?
    var createdAt: Date?
    var updatedAt: Date?
    var tags: [String]?
}
