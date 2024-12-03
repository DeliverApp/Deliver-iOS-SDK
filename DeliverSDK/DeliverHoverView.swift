//
//  DeliverWindow.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 18/11/2023.
//

import UIKit



internal protocol DeliverHoverViewDelegate: class {
    func hoverViewDidSelectScreenshot()
    func hoverViewDidSelectRecord()
}

internal class DeliverHoverView {
    
    /// Application window
    /// On which we add our tool buttons
    private var applicationWindow: UIWindow?
    
    private var hoverView: HoverView!
    
    private weak var delegate: DeliverHoverViewDelegate?
    
    // Forward visibility to the underlying view
    internal var isHidden: Bool {
        set {
            self.hoverView.isHidden = newValue
        }
        get {
            self.hoverView.isHidden
        }
    }
    
    init(delegate: DeliverHoverViewDelegate) {
        self.delegate = delegate
        self.applicationWindow = UIApplication.shared.mainWindow
        createToolsButton()
    }
 
    private func createToolsButton() {
        
        guard let window = self.applicationWindow else { fatalError("[Deliver] Can't find main application window.") }
        let logo = UIImage(named: "logo", in: Bundle.module, with: .none)
        let configuration = HoverConfiguration(
            image: logo,
            color: HoverColor.color(.white),
            imageSizeRatio: 0.4
        )
    
        // Create an HoverView with the previous configuration & items
        hoverView = HoverView(with: configuration, items: [])
        
        configureHoverDefaultItems()
        // Add to the top of the view hierarchy
        window.addSubview(hoverView)
        hoverView.translatesAutoresizingMaskIntoConstraints = false
        
        // Apply Constraints
        // Never constrain to the safe area as Hover takes care of that
        NSLayoutConstraint.activate([
            hoverView.topAnchor.constraint(equalTo: window.topAnchor),
            hoverView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            hoverView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            hoverView.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        ]
        )
    }
    
    private func configureHoverDefaultItems() {
        // Create the items to display
        let items = [
            
            HoverItem(title: "Snapshot", image: UIImage(systemName: "photo.fill")) { self.delegate?.hoverViewDidSelectScreenshot() },
            HoverItem(title: "Record", image: UIImage(systemName: "video")) { self.showAlert() },
            HoverItem(title: "Network traffic", image: UIImage(systemName: "network")) { self.showAlert() },
            HoverItem(title: "Device log", image: UIImage(systemName: "terminal.fill")) { self.showAlert() },
            HoverItem(title: "Previous issue", image: UIImage(systemName: "ant")) { self.showAlert() }
        ]
        hoverView.items = items
        hoverView.tintColor = .black
    }
    
    private func showAlert() {
        guard let window = applicationWindow else { fatalError("[Deliver] Can't find main application window.") }
        let alert = UIAlertController(title: "Not implemented", message: "This feature is not yet available.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        window.rootViewController?.present(alert, animated: true)
    }
    
   
}
