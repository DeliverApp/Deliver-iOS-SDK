//
//  JamConfiguration.swift
//  atlantis
//
//  Created by Nghia Tran on 10/23/20.
//  Copyright © 2020 Proxyman. All rights reserved.
//

import Foundation

struct JamConfiguration {

    let projectName: String
    let deviceName: String
    let id: String
    let hostName: String?

    static func `default`(hostName: String? = nil) -> JamConfiguration {
        let project = Project.current
        let deviceName = Device.current
        return JamConfiguration(projectName: project.name,
                             deviceName: deviceName.name,
                             hostName: hostName)
    }

    private init(projectName: String, deviceName: String, hostName: String?) {
        self.projectName = projectName
        self.deviceName = deviceName
        self.hostName = hostName
        self.id = "\(Project.current.bundleIdentifier)-\(JamDevice.current.model)" // Use this ID to distinguish the message
    }
}
