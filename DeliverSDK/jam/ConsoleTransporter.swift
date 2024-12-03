//
//  File.swift
//  
//
//  Created by Benjamin FROLICHER on 28/01/2024.
//

import UIKit
import Foundation

internal class ConsoleTransporter: Transporter {
    
    // Maximum package size. If package size is bigger than this value, data will be truncate
    static let MaximumSizePackage = 10_485_760 // 10Mb
    
    // Queue on wich all data will be send to deliver API
    private let queue = DispatchQueue(label: "com.deliver.jam.console") // Serial on purpose
    
    // Package to send when device will be authorized
    private var pendingPackages: [Serializable] = []
    
    // The maximum number of pending item to prevent Jam consumes too much RAM
    private let maxPendingItem = 50
    
    private var timer: Timer?
    
    internal init() {
        initNotification()
    }
    
    /// Start sending request
    func start(_ config: JamConfiguration) {
        // observe configuration here and start timer
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            queue.async {
                // Send to all connections
                self.streamToConnection()
            }
        })
    }
    
    /// Stop sending data to deliver.
    func stop() {
        pendingPackages.removeAll()
        timer?.invalidate()
    }
    
    func send(package: Message) {
        if let traffic = package.content {
            guard traffic.request.url.contains("local") == false else { return }
            var log = ["{"]
            log.append("  \"url:\" \"\(traffic.request.url)\",")
            log.append("  \"code:\" \"\(traffic.response?.statusCode ?? 0)\",")
            log.append("  \"duration:\" \"\(traffic.duration)s\",")
            log.append("  \"request\": {")
            log.append("    \"method\": \"\(traffic.request.method)\",")
            if traffic.request.headers.count > 0 {
                log.append("    \"headers\": [")
                traffic.request.headers.forEach { header in
                    log.append("      { \"\(header.key)\": \"\(header.value)\" },")
                }
                log.append("    ],")
            }
            else {
                log.append("    \"headers\": [],")
            }
            if let body = traffic.request.body,
               let bodyString = String(data: body, encoding: .utf8) {
                log.append("    \"body\": \"\(bodyString)\",")
            }
            else {
                log.append("    \"body\": null,")
            }
            log.append("  },")
            log.append("  \"response\": {")
            if traffic.response?.headers.count ?? 0 > 0 {
                log.append("    \"headers\": [")
                traffic.response?.headers.forEach { header in
                    log.append("      { \"\(header.key)\": \"\(header.value)\" },")
                }
                log.append("    ],")
            }
            else {
                log.append("    \"headers\": [],")
            }
            
            if let bodyString = String(data: traffic.responseBodyData, encoding: .utf8) {
                log.append("    \"body\": \"\(bodyString.prefix(20))...\",")
            }
            else {
                log.append("    \"body\": null,")
            }
            log.append("}")
            
            print(log.joined(separator: "\n"))            
        }
        
        self.pendingPackages.append(package)
    }
    
    private func streamToConnection() {
        queue.async { [weak self] in
            guard let self = self else { return }
            let packages = self.pendingPackages
            // Compress data by gzip
            let compressedData = packages.compactMap({ $0.toCompressedData() })
            /// Call deliver API
            
            self.pendingPackages.removeAll()
        }
    }
}

extension ConsoleTransporter {
    
    private func initNotification() {
        // Memory Warning notification is only available on iOS
        NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil,
                                               queue: nil) { [weak self] _ in
            self?.queue.async {
                self?.pendingPackages.removeAll()
            }
        }
    }
}
