//
//  SignInCoordinator.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 29/12/2023.
//

import SwiftUI
import UIKit

internal class SignInCoordinator: Coordinator<Bool> {
    
    private let navigationController: UINavigationController
    
    private let viewModel = SignInViewModel()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() {
        viewModel
            .onOpenScanner { self.openScanner() }
            .onLogginEnd { self.finish?(self, true) }
            
        let screen = SignInScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        navigationController.setViewControllers([controller], animated: false)
    }
    
    func openScanner() {
        let controller = QRCodeScannerViewController()
        controller.onScanEnd { [weak self] scanned in
            guard let self = self else { return }
            self.viewModel.receiveScan(scanned ?? "")
        }
        self.navigationController.present(controller, animated: true)
    }
    
}
