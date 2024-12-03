//
//  UIWindow+KeyWindow.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 19/12/2023.
//

import UIKit

extension UIApplication {
    
    var mainWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                return scene.windows.first ?? UIApplication.shared.windows.last
            }
        } else {
            return UIApplication.shared.windows.last
        }
        return nil
    }
}
