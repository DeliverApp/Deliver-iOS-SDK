//
//  BaseOutput.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 11/02/2023.
//

import Foundation
import OSLog

public class BaseOutput: Hashable {
    
    private var _uuid = UUID().uuidString
    
    private(set) public var queue: DispatchQueue
    
    lazy public var defaultDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Logger.dateFormat
        return formatter
    }()
    
    init() {
        let queueLabel = "deliver-log-queue-" + _uuid
        queue = DispatchQueue(label: queueLabel)
    }
    
    func write(level: OSLogType, time: Date, message: @autoclosure () -> String, thread: String, file: String, function: String, line: Int, context: Any?) {
        
    }
    
    public static func == (lhs: BaseOutput, rhs: BaseOutput) -> Bool {
        lhs._uuid == rhs._uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_uuid)
    }
}
