//
//  UIWindow+New.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 27/12/2023.
//

import UIKit

extension UIWindow {
    
    static func new() -> UIWindow? {
        
        var window: UIWindow?
        let windowScene = UIApplication.shared
            .connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first
        if let windowScene = windowScene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
        }
        return window
    }
}
