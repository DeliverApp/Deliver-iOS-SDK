//
//  Log.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 24/01/2024.
//

import Foundation
import OSLog

internal struct Log: Codable {
    
    var time: Date
    
    var level: OSLogType
    
    var file: String
    
    var function: String
    
    var line: Int
    
    var message: String
    
    var thread: String
    
    enum Key: CodingKey {
        case date
        case level
        case file
        case fct
        case line
        case message
        case thread
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: Key.self)
        switch level {
            case .debug:
                try container.encode("DEBUG", forKey: .level)
            case .error:
                try container.encode("ERROR", forKey: .level)
            case .fault:
                try container.encode("FAULT", forKey: .level)
                
            default: // .info, .default and defaut
                try container.encode("INFO", forKey: .level)
        }
        
        try container.encode(time, forKey: .date)
        try container.encode(file, forKey: .file)
        try container.encode(function, forKey: .fct)
        try container.encode(line, forKey: .line)
        try container.encode(message, forKey: .message)
        try container.encode(thread, forKey: .thread)
    }
}


extension OSLogType: Codable {}
