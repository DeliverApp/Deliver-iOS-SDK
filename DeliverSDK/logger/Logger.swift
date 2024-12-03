//
//  Logger.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 05/02/2023.
//

import Foundation
import OSLog


/// `Logger` is a lightweight and extensible logging library. It offers several pre-built loggers, such as `os_log` (for system logging) and a file-based logger.
/// The library also supports creating custom loggers output by implementing the `BaseOutput` protocol.

/// This class provides a variety of logging methods for different severity levels, making it suitable for debugging, informational messages, warnings, and errors.
/// Additionally, it allows flexible configuration of log outputs.

public final class Logger {

    /// The date format used in log messages. Modify this to customize the timestamp format for log entries.
    public static var dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    private static var outputs = Set<BaseOutput>()
    
    private init() {}

    // MARK: Destination Handling
    
    
    /// Adds a logging output destination.
    ///
    /// - Parameter output: An instance conforming to the `BaseOutput` protocol, representing the output destination for log messages (e.g., file, console, or custom implementation).
    /// - Returns: A boolean indicating whether the output was successfully added.
    @discardableResult
    public class func addOutput(_ output: BaseOutput) -> Bool {
        if outputs.contains(output) {
            return false
        }
        outputs.insert(output)
        return true
    }
    
    /// Removes a previously added logging output destination.
    ///
    /// - Parameter output: The `BaseOutput` instance to be removed.
    /// - Returns: A boolean indicating whether the output was successfully removed.
    @discardableResult
    public class func removeOutput(_ output: BaseOutput) -> Bool {
        if outputs.contains(output) == false {
            return false
        }
        outputs.remove(output)
        return true
    }
    
    
    /// Retrieves the current thread name.
    ///
    /// - Returns: A string representing the name of the thread executing the logging operation.
    class func threadName() -> String {
        if Thread.isMainThread {
            return "Main"
        } else {
            let name = __dispatch_queue_get_label(nil)
            return String(cString: name, encoding: .utf8) ?? Thread.current.description
        }
    }
    
    // MARK: Levels
    
    /// Logs a debug message.
    ///
    /// Use this method for low-priority messages that assist in debugging but are not critical.
    ///
    /// - Parameters:
    ///  - message: A closure returning the message to be logged.
    ///  - file: The name of the file where the log call is made. Default is the current file (`#file`).
    ///  - function: The name of the function where the log call is made. Default is the current function (`#function`).
    ///  - line: The line number in the file where the log call is made. Default is the current line (`#line`).
    ///  - context: Optional additional context for the log message. Default is `nil`.
    public class func debug(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {
        send(level: .debug, time: Date(), message: message(), thread: threadName(), file: file, function: function, line: line, context: context)
    }
    
    /// Logs an informational message.
    ///
    /// Use this method for normal-priority messages that highlight system activity or important events.
    ///
    /// - Parameters:
    ///   - message: A closure returning the message to be logged.
    ///   - file: The name of the file where the log call is made. Default is the current file (`#file`).
    ///   - function: The name of the function where the log call is made. Default is the current function (`#function`).
    ///   - line: The line number in the file where the log call is made. Default is the current line (`#line`).
    ///   - context: Optional additional context for the log message. Default is `nil`.
    public class func info(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {
        send(level: .info, time: Date(), message: message(), thread: threadName(), file: file, function: function, line: line, context: context)
    }
    
    /// Logs an error message.
    ///
    /// Use this method for high-priority messages that indicate a serious issue.
    ///
    /// - Parameters:
    ///   - message: A closure returning the message to be logged.
    ///   - file: The name of the file where the log call is made. Default is the current file (`#file`).
    ///   - function: The name of the function where the log call is made. Default is the current function (`#function`).
    ///   - line: The line number in the file where the log call is made. Default is the current line (`#line`).
    ///   - context: Optional additional context for the log message. Default is `nil`.
    public class func error(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {
        send(level: .error, time: Date(), message: message(), thread: threadName(), file: file, function: function, line: line, context: context)
    }
    
    /// Logs a fault message.
    ///
    /// Use this method for messages that indicate imminent severe issues or system failures.
    ///
    /// - Parameters:
    ///   - message: A closure returning the message to be logged.
    ///   - file: The name of the file where the log call is made. Default is the current file (`#file`).
    ///   - function: The name of the function where the log call is made. Default is the current function (`#function`).
    ///   - line: The line number in the file where the log call is made. Default is the current line (`#line`).
    ///   - context: Optional additional context for the log message. Default is `nil`.
    public class func fault(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {
        send(level: .fault, time: Date(), message: message(), thread: threadName(), file: file, function: function, line: line, context: context)
    }
    
    // MARK: - Private
    
    /// internal helper which dispatches send to dedicated queue if minLevel is ok
    private class func send(level: OSLogType, time: Date, message: @autoclosure () -> String, thread: String, file: String, function: String, line: Int, context: Any?) {
        for output in outputs {
            output.write(level: level, time: time, message: message(), thread: thread, file: fileNameOfFile(file), function: function, line: line, context: context)
        }
    }
    
    /// returns the filename of a path
    private class func fileNameOfFile(_ file: String) -> String {
        let fileParts = file.components(separatedBy: "/")
        if let lastPart = fileParts.last {
            return lastPart
        }
        return ""
    }
    
}

