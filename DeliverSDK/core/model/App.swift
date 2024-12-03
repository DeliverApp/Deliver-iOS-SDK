//
//  App.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 30/12/2023.
//

import Foundation

internal struct App: Codable {
    var id: String
    var name: String
    var icon: String?
    var bundleId: String
    var platform: String
    var createdAt: Date
    var updatedAt: Date
    var companyId: String
    var tags: [String]?
}
