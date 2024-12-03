//
//  ConsoleOutput.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 11/02/2023.
//

import Foundation
import OSLog

private extension OSLogType {
    var color: String {
        switch self {
            case .default: return "🟢"
            case .debug: return "🟢"
            case .info: return "🔵"
            case .error: return "🔴"
            case .fault: return "☠️"
            default: return "🟢"
        }
    }
}

internal final class ConsoleOutput: BaseOutput {
        
    internal override init() {
        super.init()
    }
    
    internal override func write(level: OSLogType, time: Date, message: @autoclosure () -> String, thread: String, file: String, function: String, line: Int, context: Any?) {
        
        var texts = [String]()
        texts.append(level.color)
        texts.append(defaultDateFormatter.string(from: time))
        texts.append(thread)
        texts.append(file)
        texts.append(function)
        texts.append("\(line)")
        texts.append(message())
        
        let text = texts.joined(separator: " ")
//        logger.log(level: level, text)
        print(text)
        
    }
}

