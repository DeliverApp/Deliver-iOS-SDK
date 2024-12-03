//
//  Build.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 30/12/2023.
//

import Foundation

internal struct Build: Codable {
    var id: String
    var branch: String
    var buildNumber: String
    var commitHash: String
    var commitMessage: String?
    var pipelineId: String
    var customerIssue: String
    var version: String
    var appId: String
    var committerId: String
    var tags: [String]?
    var status: String?
    var validatorsId:  [String]?
    var deniesId: [String]?
    var binary: String?
    var createdAt: Date
    var updatedAt: Date
}
