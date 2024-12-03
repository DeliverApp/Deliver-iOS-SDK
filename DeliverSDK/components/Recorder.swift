//
//  Recorder.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 21/12/2023.
//

import UIKit
import AVFoundation
import ReplayKit
import Photos

internal class Recorder {
    
    /// Unique instance of Recoder
    static let shared: Recorder = Recorder()
    
    internal var isRecording: Bool = false
    
    /// Queue on which all movie recording actions are performed
    private let queue = DispatchQueue(label: "com.deliver.recorder", qos: .default)
    
    private var videoInput: AVAssetWriterInput!
    
    private var assetWriter: AVAssetWriter!
    
    /// Hide default init. Use `shared` instead
    private init() {}
    
    /// Start recording screen and save video at in path returned when stopped
    func startRecord() {
        guard isRecording == false else { return }
        isRecording = true
        
        if let window = UIApplication.shared.mainWindow {
            let topInset: CGFloat = window.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
            let view = UIView(frame: CGRect(x: 0, y: 0, width: window.bounds.size.width, height: topInset))
            view.backgroundColor = .red
            window.addSubview(view)
            view.addGestureRecognizer(ClosureTapGestureRecognizer(action: {
                Task {await self.stopRecord()}
            }))
        }
        
        // Configure record settings
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Deliver", isDirectory: true)
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        assetWriter = try! AVAssetWriter(outputURL: url, fileType: .mp4)
        
        let videoOutputSettings: Dictionary<String, Any> = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: UIScreen.main.bounds.size.width * 2,
            AVVideoHeightKey: UIScreen.main.bounds.size.height * 2
        ]
        
        videoInput  = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = true
        assetWriter.add(videoInput)
        // Launch record
        RPScreenRecorder.shared().startCapture(handler: { (sample, bufferType, error) in
            if CMSampleBufferDataIsReady(sample) {
                self.queue.async { [weak self] in
                    guard let self = self else { return }
                    if self.assetWriter.status == .unknown {
                        self.assetWriter.startWriting()
                        self.assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sample))
                    }
                    
                    if self.assetWriter.status == .failed {
                        //print("Asset writer in error \(self.assetWriter.status.rawValue) \(self.assetWriter.error!.localizedDescription) \(self.assetWriter.error!)")
                        return
                    }
                    
                    if bufferType == .video {
                        if self.videoInput.isReadyForMoreMediaData {
                            self.videoInput.append(sample)
                        }
                    }
                }
            }
        }) { error in
            //print(error.debugDescription)
        }
    }
    
    /// Stop the current screen recording and return the file URL
    func stopRecord() async -> URL? {
        await withCheckedContinuation { continuation in
            RPScreenRecorder.shared().stopCapture { error in
                self.videoInput.markAsFinished()
                self.assetWriter.finishWriting {
                    self.isRecording = false
                    continuation.resume(returning: self.assetWriter.outputURL)
                }
            }
        }
    }
    
    func screenshot(_ window: UIWindow) async -> URL? {
        
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Deliver", isDirectory: true)
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("png")
        
        DispatchQueue.main.async {
            let renderer = UIGraphicsImageRenderer(size: window.bounds.size)
            let image = renderer.image { ctx in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
            
            let data = image.jpegData(compressionQuality: 1.0)
            
            do {
                try data?.write(to: url, options: [.atomic])
            }
            catch {
                
            }
        }
        
        return await withUnsafeContinuation { continuation in
            DispatchQueue.main.async {
                self.animateScreenshot(window: window) {
                    continuation.resume(returning: url)
                }
            }
        }
    }
    
    private func animateScreenshot(window: UIWindow, completion: @escaping (() -> Void)) {
        
        let flash = UIView(frame: window.bounds)
        flash.backgroundColor = .white
        window.addSubview(flash)
        UIView.animate(withDuration: 0.2) {
            flash.alpha = 0
        } completion: { _ in
            flash.removeFromSuperview()
            completion()
        }
    }
}
