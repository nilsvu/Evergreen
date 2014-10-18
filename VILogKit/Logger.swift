//
//  Logger.swift
//  VILogKit
//
//  Created by Nils Fischer on 19.08.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//


import Foundation


public func log<M>(message: M, forLevel logLevel: LogLevel? = nil, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__)
{
    // TODO: filename processing.. there has to be a better way
    let filenameComponents = file.lastPathComponent.componentsSeparatedByString(".")
    let logger = Logger.loggerForKeyPath(filenameComponents[0])
    logger.log(message, forLevel: logLevel, function: function, file: file, line: line)
}


/// The default logger singleton
private let _defaultLogger: Logger = {
    let logger = Logger(key: "Default", parent: nil)
    logger.handlers.append(ConsoleHandler())
    return logger
}()


/// The queue used for logging
internal let loggingQueue = NSOperationQueue() // TODO: use to fix unordered println output


public final class Logger {
    
    
    // MARK: Public Properties

    /// This logger will only log records with equal or higher log levels. If no log level is specified, all records will be logged.
    public var logLevel: LogLevel?
    /// Returns the effective log level by reaching up the logger hierarchy until a logger specifies a log level.
    public var effectiveLogLevel: LogLevel? {
        if let logLevel = self.logLevel {
            return logLevel
        } else {
            if let parent = self.parent {
                return parent.effectiveLogLevel
            } else {
                return logLevel
            }
        }
    }
    
    /// The handlers provided by this logger to process log records.
    public var handlers = [Handler]()
    
    /// Passes log records up the logger hirarchy if set to true (default)
    public var shouldPropagate = true

    /// The parent in the logger hirarchy
    public let parent: Logger?
    private var children = [ String : Logger]()
    
    /// The key used to identify this logger
    public let key: String


    // MARK: Initialization
    
    /// Creates a new logger. If you don't specify a parent, the logger is detached from the logger hirarchy and will not have any handlers.
    public init(key: String, parent: Logger?) {
        self.key = key
        self.parent = parent
        parent?.children[key.lowercaseString] = self
    }
    
    
    // MARK: Logging
    
    public func log<M>(message: M, forLevel logLevel: LogLevel? = nil, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__)
    {
        let record = Record(logger: self, message: message, logLevel: logLevel, date: NSDate(), function: function, file: file, line: line)
        
        if let effectiveLogLevel = self.effectiveLogLevel {
            if let recordLogLevel = record.logLevel {
                if recordLogLevel < effectiveLogLevel {
                    return
                }
            }
        }
        
        self.handleRecord(record)
    }
    
    private func handleRecord<M>(record: Record<M>)
    {
        for handler in handlers {
            handler.emitRecord(record)
        }
        if shouldPropagate {
            if let parent = self.parent {
                parent.handleRecord(record)
            }
        }
    }
    

    // MARK: Logger Hierarchy
    
    /// The default logger is the root of the logger hirarchy.
    public class func defaultLogger() -> Logger {
        return _defaultLogger
    }

    /// Returns the logger for the specified key path. A key path is a dot-separated string of keys like "MyModule.MyClass" describing the logger hirarchy relative to the default logger. Always returns the same logger object for a given key path. A parent-children relationship is established and can be used to set specific settings like log levels and handlers for only parts of the logger hirarchy.
    public class func loggerForKeyPath(keyPath: String) -> Logger {
        let components = keyPath.componentsSeparatedByString(".")
        var currentLogger = defaultLogger()
        for component in components {
            if component.lowercaseString == defaultLogger().key.lowercaseString {
                continue
            }
            if let componentLogger = currentLogger.children[component.lowercaseString] {
                currentLogger = componentLogger
            } else {
                currentLogger = Logger(key: component, parent: currentLogger)
            }
        }
        return currentLogger
    }

}


// MARK: - Printable

extension Logger: Printable {

    public var description: String {
        if let parent = self.parent {
            if parent === Logger.defaultLogger() {
                return key
            } else {
                return parent.description + "." + key
            }
        } else {
            if self === Logger.defaultLogger() {
                return key
            } else {
                return "DETACHED." + key
            }
        }
    }

}


// MARK: - Log Level Enum

public enum LogLevel: Int, Printable, Comparable {

    case All = 0, Verbose, Debug, Info, Warning, Critical, Off

    public var description: String {
        switch self {
            case .All: return "All"
            case .Verbose: return "Verbose"
            case .Debug: return "Debug"
            case .Info: return "Info"
            case .Warning: return "Warning"
            case .Critical: return "Critical"
            case .Off: return "Off"
        }
    }
}

public func == (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.toRaw() == rhs.toRaw()
}

public func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.toRaw() < rhs.toRaw()
}


// MARK: - Log Message Struct

public struct Record<M> {
    
    /// The original logger that initiating the logging
    let logger: Logger // TODO: use keyPath instead?
    
    /// The log message
    public let message: M
    /// The log level. A logger will only log records with equal or higher log levels than its own. Records that don't specify a log level will always be logged.
    public let logLevel: LogLevel?
    public let date: NSDate
    
    public let function: String
    public let file: String
    public let line: Int
    
}


// MARK: - Loggable Protocol

// TODO: define Loggable protocol as a constraint for generic message type M.
//public typealias Loggable = DebugPrintable

