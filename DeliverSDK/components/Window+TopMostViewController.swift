
//
//  SnaptshotViewController.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 18/12/2023.
//

import UIKit


/// Window extension to find the top most visible controller
internal extension UIWindow {
    
    func topMostViewController() -> UIViewController? {
        guard let rootViewController = self.rootViewController else {
            return nil
        }
        return UIWindow.getTopMostViewController(from: rootViewController)
    }
    
    private static func getTopMostViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return getTopMostViewController(from: presentedViewController)
        } else if let navigationController = viewController as? UINavigationController {
            return getTopMostViewController(from: navigationController.visibleViewController ?? navigationController)
        } else if let tabBarController = viewController as? UITabBarController {
            return getTopMostViewController(from: tabBarController.selectedViewController ?? tabBarController)
        } else {
            return viewController
        }
    }
}
