//
//  Logger.swift
//  Evergreen
//
//  Created by Nils Fischer on 19.08.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//


import Foundation


// MARK: Global Interface

/// The default logger singleton
public let defaultLogger: Logger = {
    let logger = Logger(key: "Default", parent: nil)
    logger.handlers.append(ConsoleHandler())
    return logger
}()

/// The default logger's log level
public var logLevel: LogLevel? {
    get {
        return defaultLogger.logLevel
    }
    set {
        defaultLogger.logLevel = newValue
    }
}

/// Logs an event using a logger that is appropriate for the caller.
public func log<M>(message: M, forLevel logLevel: LogLevel? = nil, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__)
{
    Logger.loggerForFile(file: file).log(message, forLevel: logLevel, function: function, file: file, line: line)
}

/// Reads the logging configuration from environment variables. Every environment variable with prefix 'Evergreen' is evaluated as a logger key path and assigned a log level corresponding to its value. Values should match the log level descriptions, e.g. 'Debug'. Valid environment variable declarations would be e.g. 'Evergreen = Debug' or 'Evergreen.MyLogger = Verbose'.
public func configureFromEnvironment()
{
    let prefix = "Evergreen"
    if let environmentVariables = NSProcessInfo.processInfo().environment as? [String: String] {
        var configurations = [(Logger, LogLevel)]()
        for (key, value) in environmentVariables {
            if key.hasPrefix(prefix) {
                let (_, keyPath) = Logger.KeyPath(string: key).popFirst()
                let logger = Logger.loggerForKeyPath(keyPath)
                if let logLevel = LogLevel(description: value) {
                    logger.logLevel = logLevel
                    configurations.append((logger, logLevel))
                } else {
                    log("Invalid Evergreen log level '\(value)' for key path '\(keyPath)' in environment variable.", forLevel: .Warning)
                }
            }
        }
        if configurations.count > 0 {
            log("Configured Evergreen logging from environment. Configurations: \(configurations)", forLevel: .Debug)
        }
    } else {
        log("Could not process environment variables. Evergreen logging ist not configured.", forLevel: .Warning)
    }
}


/// The queue used for logging
internal let loggingQueue = NSOperationQueue() // TODO: use to fix unordered println output


// MARK: Logger

public final class Logger {
    
    
    // MARK: Public Properties

    /// This logger will only log events with equal or higher log levels. If no log level is specified, all events will be logged.
    public var logLevel: LogLevel?
    /// Returns the effective log level by reaching up the logger hierarchy until a logger specifies a log level.
    public var effectiveLogLevel: LogLevel? {
        if let logLevel = self.logLevel {
            return logLevel
        } else {
            if let parent = self.parent {
                return parent.effectiveLogLevel
            } else {
                return nil
            }
        }
    }
    
    /// The handlers provided by this logger to process log events.
    public var handlers = [Handler]()
    
    /// Passes events up the logger hierarchy if set to true (default)
    public var shouldPropagate = true

    /// The parent in the logger hierarchy
    public let parent: Logger?
    public private(set) var children = [ String : Logger]()
    public var root: Logger {
        if let parent = parent {
            return parent.root
        } else {
            return self
        }
    }
    
    /// The key used to identify this logger
    public let key: String
    public var keyPath: KeyPath {
        return self.keyPath()
    }
    public func keyPath(upToParent excludedLogger: Logger? = nil) -> KeyPath {
        if let parent = self.parent where !(excludedLogger != nil && parent === excludedLogger!) {
            return parent.keyPath.keyPathByAppendingComponent(self.key)
        } else {
            return KeyPath(components: [ self.key ])
        }
    }


    // MARK: Initialization
    
    /// Creates a new logger. If you don't specify a parent, the logger is detached from the logger hierarchy and will not have any handlers.
    public init(key: String, parent: Logger?) {
        self.key = key
        self.parent = parent
        parent?.children[key] = self
    }
        

    // MARK: Intial Info
    
    private var hasLoggedInitialInfo: Bool = false
    public func logInitialInfo() {
        if !hasLoggedInitialInfo {
            if handlers.count > 0 {
                let event = Event(logger: self, message: "Logging to \(handlers)...", logLevel: .Info, date: NSDate(), elapsedTime: nil, function: __FUNCTION__, file: __FILE__, line: __LINE__)
                self.handleEvent(event)
            }
            hasLoggedInitialInfo = true
        }
        if shouldPropagate {
            if let parent = self.parent {
                parent.logInitialInfo()
            }
        }
    }

    
    // MARK: Logging
    
    public func log<M>(message: M, forLevel logLevel: LogLevel? = nil, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__)
    {
        let event = Event(logger: self, message: message, logLevel: logLevel, date: NSDate(), elapsedTime: nil, function: function, file: file, line: line)
        self.logEvent(event)
    }
    
    public func logEvent<M>(event: Event<M>)
    {
        self.logInitialInfo()
        
        if let effectiveLogLevel = self.effectiveLogLevel, let eventLogLevel = event.logLevel where eventLogLevel < effectiveLogLevel {
            return
        } else {
            self.handleEvent(event)
        }
    }
    
    private func handleEvent<M>(event: Event<M>, var wasHandled: Bool = false)
    {
        for handler in handlers {
            handler.emitEvent(event)
            wasHandled = true
        }
        if let parent = self.parent where shouldPropagate {
            parent.handleEvent(event, wasHandled: wasHandled)
        } else {
            if !wasHandled {
                // TODO: use println() directly? Using log() will cause an endless loop when defaultLogger does not have any handlers.
                println("Tried to log an event for logger '\(event.logger)', but no handler was found in the logger hierarchy to emit the event: \(event.file.lastPathComponent):\(event.line) \(event.function)")
            }
        }
    }
    
    
    // MARK: Measuring Time
    
    private var defaultStartDate: NSDate?
    private lazy var startDates = [String : NSDate]()
    
    // TODO: log "Tic..." message by default
    public func tic<M>(andLog message: M, forLevel logLevel: LogLevel? = nil, timerKey: String? = nil, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__)
    {
        if let timerKey = timerKey {
            startDates[timerKey] = NSDate()
        } else {
            defaultStartDate = NSDate()
        }
        self.log(message, forLevel: logLevel, function: function, file: file, line: line)
    }
    
    // TODO: log "...Toc" message by default
    public func toc<M>(andLog message: M, forLevel logLevel: LogLevel? = nil, timerKey: String? = nil, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__)
    {
        var startDate: NSDate?
        if let timerKey = timerKey {
            startDate = startDates[timerKey]
        } else {
            startDate = defaultStartDate
        }
        if let startDate = startDate {
            let elapsedTime = NSDate().timeIntervalSinceDate(startDate)
            let event = Event(logger: self, message: message, logLevel: logLevel, date: NSDate(), elapsedTime: elapsedTime, function: function, file: file, line: line)
            self.logEvent(event)
        }
    }

    
    // MARK: Logger Hierarchy
    
    /// The default logger is the root of the logger hierarchy.
    public class func defaultLogger() -> Logger {
        return Evergreen.defaultLogger
    }
    
    public class func loggerForKey(key: String, parent: Logger) -> Logger {
        return parent.childForKeyPath(KeyPath(components: [ key ]))
    }
    
    public class func loggerForFile(file: String = __FILE__) -> Logger {
        // TODO: filename processing.. there has to be a better way
        var key = file.lastPathComponent//.componentsSeparatedByString(".").first!
        return self.loggerForKeyPath(KeyPath(components: [ key ]))
    }
    
    /// Returns the logger for the specified key path. A key path is a dot-separated string of keys like "MyModule.MyClass" describing the logger hierarchy relative to the default logger. Always returns the same logger object for a given key path. A parent-children relationship is established and can be used to set specific settings like log levels and handlers for only parts of the logger hierarchy.
    public class func loggerForKeyPath(keyPath: Logger.KeyPath) -> Logger {
        let (key, remainingKeyPath) = keyPath.popFirst()
        if let key = key {
            if key == self.defaultLogger().key {
                return self.defaultLogger().childForKeyPath(remainingKeyPath)
            } else {
                return self.defaultLogger().childForKeyPath(keyPath)
            }
        } else {
            return self.defaultLogger()
        }
    }

    public func childForKeyPath(keyPath: KeyPath) -> Logger {
        let (key, remainingKeyPath) = keyPath.popFirst()
        if let key = key {
            let child = children[key] ?? Logger(key: key, parent: self)
            return child.childForKeyPath(remainingKeyPath)
        } else {
            return self
        }
    }
    
    // MARK: Key Path Struct
    
    public struct KeyPath: StringLiteralConvertible, Printable {
        
        public let components: [String]

        public init(components: [String]) {
            self.components = components
        }
        
        public init(string: String) {
            self.components = string.componentsSeparatedByString(".").filter { !$0.isEmpty }
        }

        public func keyPathByPrependingComponent(component: String) -> KeyPath {
            return KeyPath(components: [ component ] + components)
        }
        public func keyPathByAppendingComponent(component: String) -> KeyPath {
            return KeyPath(components: components + [ component ])
        }

        public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
        public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
            self.components = value.componentsSeparatedByString(".").filter { !$0.isEmpty }
        }
        public typealias UnicodeScalarLiteralType = StringLiteralType
        public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
            self.components = value.componentsSeparatedByString(".").filter { !$0.isEmpty }
        }
        public init(stringLiteral value: StringLiteralType) {
            self.components = value.componentsSeparatedByString(".").filter { !$0.isEmpty }
        }
        
        public func popFirst() -> (key: String?, remainingKeyPath: KeyPath) {
            let key = components.first
            let remainingKeyPath: KeyPath = (components.count > 1) ? KeyPath(components: Array(components[1..<components.count])) : KeyPath(components: [String]())
            return (key, remainingKeyPath)
        }
        
        public var description: String {
            return description()
        }
        
        public func description(separator: String? = nil) -> String {
            return (separator ?? ".").join(components)
        }
    }

}


// MARK: - Printable

extension Logger: Printable {
    
    public var description: String {
        return self.description()
    }
    
    public func description(keyPathSeparator: String? = nil) -> String {
        var keyPath = self.keyPath(upToParent: defaultLogger)
        if self.root !== defaultLogger {
            keyPath = keyPath.keyPathByPrependingComponent("DETACHED")
        }
        return keyPath.description(separator: keyPathSeparator)
    }

}


// MARK: - Log Level Enum

public enum LogLevel: Int, Printable, Comparable {

    case All = 0, Verbose, Debug, Info, Warning, Error, Critical, Off

    public var description: String {
        switch self {
            case .All: return "All"
            case .Verbose: return "Verbose"
            case .Debug: return "Debug"
            case .Info: return "Info"
            case .Warning: return "Warning"
            case .Error: return "Error"
            case .Critical: return "Critical"
            case .Off: return "Off"
        }
    }
    
    public init?(var description: String) {
        description = description.lowercaseString
        var i = 0
        while let logLevel = LogLevel(rawValue: i) {
            if logLevel.description.lowercaseString == description {
                self = logLevel
                return
            }
            i++
        }
        return nil
    }
}

public func == (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

public func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}


// MARK: - Log Event Struct

public struct Event<M> {
    
    /// The logger that originally logged the event
    let logger: Logger
    /// The log message
    let message: M
    /// The log level. A logger will only log events with equal or higher log levels than its own. Events that don't specify a log level will always be logged.
    let logLevel: LogLevel?
    let date: NSDate
    let elapsedTime: NSTimeInterval?
    
    let function: String
    let file: String
    let line: Int
    
}


// MARK: - Loggable Protocol

// TODO: define Loggable protocol as a constraint for generic message type M.
//public typealias Loggable = DebugPrintable

