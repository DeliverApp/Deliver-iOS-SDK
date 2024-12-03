//
//  Device.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 24/01/2024.
//

import Foundation
import UIKit

internal struct Device: Codable {
    var id: Int = 0
    let name: String
    let version: String
    let brand: String
    
    internal static var current: Device {
        return Device(
            name: UIDevice.current.name,
            version: UIDevice.current.systemVersion,
            brand: UIDevice.current.model
        )
    }
}
