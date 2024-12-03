//
//  DeliverOutput.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 12/02/2023.
//

import Foundation
import UIKit
import OSLog
import Combine

internal final class DeliverLogOutput: BaseOutput {
    
    private var logs = [Log]()
    private var sendLogTimer: Timer?
    private var bag = Set<AnyCancellable>()
    private var isAlreadyActive = false
    private var requestInProgress = false
    private let networkQueue = DispatchQueue(label: "com.deliver.logger.network")
    
    override internal init() {
        
        super.init()
        Context.shared.$isLogActive.sink { [weak self] active in
            guard let self = self else { return }
            if active && self.isAlreadyActive == false {
                isAlreadyActive = true
                DispatchQueue.main.async {
                    self.startLogging()
                }
            }
            else if active == false && isAlreadyActive == true {
                isAlreadyActive = false
            }
        }.store(in: &bag)
        
        
    }
    
    internal override func write(level: OSLogType, time: Date, message: @autoclosure () -> String, thread: String, file: String, function: String, line: Int, context: Any?) {
        let log = Log(time: time, level: level, file: file, function: function, line: line, message: message(), thread: thread)
        self.logs.append(log)
    }
    
    func startLogging() {
        sendLogTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
            Task {
                guard self?.isAlreadyActive == true else { return }
                self?.sendLogIfPossible()
            }
        }
    }
    
    func sendLogIfPossible() {
        guard isAlreadyActive && requestInProgress == false else { sendLogTimer?.invalidate(); return }
        guard let buildId = Context.shared.build?.id else { return }
        
        networkQueue.async {
            Task {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try? encoder.encode(self.logs)
                var request = URLRequest(url: URL(string: "\(Context.shared.apiBaseUrl)/live/logs/\(buildId)/\(Context.shared.sessionId)")!)
                request.httpMethod = "POST"
                request.addValue("application/json",forHTTPHeaderField: "Content-Type")
                request.addValue("application/json",forHTTPHeaderField: "Accept")
                request.httpBody = data
                self.requestInProgress = true
                _ = try await URLSession.shared.data(for: request)
                self.requestInProgress = false
                self.logs.removeAll()
            }
        }
    }
}
