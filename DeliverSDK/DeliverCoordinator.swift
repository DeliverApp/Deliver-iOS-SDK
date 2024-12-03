//
//  DeliverCoordinator.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 27/11/2024.
//

import UIKit
import Foundation
import AVKit
import AVFoundation
import SwiftUI

internal class DeliverCoordinator {
    
    private var hoverView: DeliverHoverView!
    
    /// Application window is detected when hover is displayed
    private var applicationWindow: UIWindow?
    
    private var iamTimer: Timer?
    
    func start() {
        FontLoader.load()
        FileLoader.load()
        
        let console = ConsoleOutput()
        let deliver = DeliverLogOutput()
        Logger.addOutput(console)
        Logger.addOutput(deliver)
        
        Atlantis.start()
        
        displayOverViewDeferred(by: 3)
    }
    
    func displayOverViewDeferred(by time: TimeInterval) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [weak self] in
            guard let self = self else { return }
            self.applicationWindow = UIApplication.shared.mainWindow
            self.hoverView = DeliverHoverView(delegate: self)
            showAuth()
        }
    }
}


extension DeliverCoordinator: DeliverHoverViewDelegate {
    
    func hoverViewDidSelectScreenshot() {
        self.screenshot()
    }
    
    func hoverViewDidSelectRecord() {
        self.record()
    }
}


extension DeliverCoordinator {
    
    /// Create a snapshot and display edition mode
    func screenshot() {
        guard let window = applicationWindow else { fatalError("[Deliver] Can't find main application window.") }
        hoverView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            Task {
                if let image = await Recorder.shared.screenshot(window) {
                    self.showEditSnapshots(image)
                    self.hoverView.isHidden = false
                }
            }
        }
    }
    
    /// Create a video record of the screen
    func record() {
        //        let recorder = RPScreenRecorder.shared()
        //        recorder.isMicrophoneEnabled = false
        //        recorder.startRecording { (error) in
        //            print(error)
        //        }
        //
        Recorder.shared.startRecord()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            print("Stop record")
            Task {
                let url = await Recorder.shared.stopRecord()
                
                let player = AVPlayer(url: url!)
                
                let vc = AVPlayerViewController()
                vc.player = player
                
                self.applicationWindow?.rootViewController?.present(vc, animated: true) { vc.player?.play() }
            }
            //            recorder.stopRecording(withOutput: url) { error in
            //
            //            }
            //            recorder.stopRecording { previewViewController, error in
            //
            //                print("stopRecording")
            //                print(previewViewController)
            //                print(error)
            //                guard let previewViewController else { return }
            //                self.applicationWindow?.rootViewController?.present(previewViewController, animated: true)
            //            }
        }
    }
    
    func showAuth() {
        guard let window = applicationWindow else { fatalError("[Deliver] Can't find main application window.") }
        let viewModel = SignInViewModel()
        
        let screen = SignInScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        
        viewModel.onLogginEnd { [weak self] in
            controller.dismiss(animated: true)
            self?.fetchBuild()
        }
        if let topController = window.topMostViewController() {
            controller.isModalInPresentation = true
            topController.present(controller, animated: true, completion: nil)
        }
    }
    
    func showEditSnapshots(_ snapshot: URL) {
        guard let window = applicationWindow else { fatalError("[Deliver] Can't find main application window.") }
        let preview = SnaptshotViewController(snapshot: snapshot)
        preview.onEndEditing { url in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.createIssue(media: url)
            }
        }
        window.rootViewController?.present(preview, animated: true)
    }
    
    func createIssue(media: URL) {
        
        guard let window = applicationWindow else { fatalError("[Deliver] Can't find main application window.") }
        let viewModel = EditIssueViewModel(media: media)
        
        let screen = EditIssueScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isModalInPresentation = true
        
        viewModel.onClose {
            controller.dismiss(animated: true)
        }
        
        window.rootViewController?.present(navigationController, animated: true)
        
        
    }
}


extension DeliverCoordinator {
    
    private func fetchBuild() {
       
        Task {
            let api = BuildAPI()
            let build = try? await api.current()
            Context.shared.build = build
            if let id = build?.id {
                try? await api.testing(buildId: id)
            }
            DispatchQueue.main.async {
                self.startIam()
            }
        }
    }
    
    internal func startIam() {
        iamTimer = .scheduledTimer(withTimeInterval: 2, repeats: true, block: {  [weak self] _ in
            Task {
                try? await self?.iam()
            }
        })
        RunLoop.current.add(iamTimer!, forMode: .common)
    }
    
   
    
    struct Iam {
        struct Request: Codable {
            var device: Device
            var sessionId = Context.shared.sessionId
        }
        
        struct Response: Codable {
            var deviceId: Int
            var active: Bool
        }
    }
    
    private func iam() async throws {
        guard let accessToken = Context.shared.acccessToken else { throw DeliverError.authenticationRequired }
        guard let buildId = Context.shared.build?.id else { return  }

        var request = URLRequest(url: URL(string: "\(Context.shared.apiBaseUrl)/live/\(buildId)/iam")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        request.httpBody = try! JSONEncoder().encode(Iam.Request(device: Device.current))
        let (data, _) = try! await URLSession.shared.data(for: request)
        let response = try! JSONDecoder().decode(Iam.Response.self, from: data)
       
        if response.active && Context.shared.isLogActive == false {
            Context.shared.isLogActive = true
        }
        else if response.active == false && Context.shared.isLogActive == true {
            Context.shared.isLogActive = false
        }
    }
}
