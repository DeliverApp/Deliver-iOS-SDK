//
//  Deliver.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 17/11/2023.
//

import Foundation
import UIKit
import CoreGraphics

/// Welcome to Deliver 😁
///
/// Using Deliver is simple as calling a function
/// Just import Deliver SDK in your application delegate and call `Deliver.setup(key: String)`
public final class Deliver {
   
    private var context = Context.shared
    
    private var coordinator: DeliverCoordinator!
    
    /// Initialize Deliver with your application API Key
    public static func setup(key: String) {
        /// internal deliver setup
        Deliver.shared.setup(key: key)
    }
}

internal extension Deliver {
    
    static var shared: Deliver = Deliver()
    
    private func setup(key: String) {
        Context.shared.key = key
        coordinator = DeliverCoordinator()
        coordinator.start()
    }
}
