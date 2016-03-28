//
//  Logger.swift
//  Evergreen
//
//  Created by Nils Fischer on 19.08.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//


import Foundation


// MARK: - Global Interface

/// The root of the logger hierarchy
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

/// Returns the logger for the specified key path. See `Logger.loggerForKeyPath:` for further documentation.
public func getLogger(keyPath: Logger.KeyPath) -> Logger {
    return Logger.loggerForKeyPath(keyPath)
}

/// Returns an appropriate logger for the given file. See `Logger.loggerForFile:` for further documentation.
public func getLoggerForFile(file: String = #file) -> Logger {
    return Logger.loggerForFile(file)
}

/// Logs the event using a logger that is appropriate for the caller. See `Logger.log:forLevel:` for further documentation.
public func log<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, forLevel logLevel: LogLevel? = nil, function: String = #function, file: String = #file, line: Int = #line)
{
    Logger.loggerForFile(file).log(message, error: error, forLevel: logLevel, function: function, file: file, line: line)
}

/// Logs the event with the Verbose log level using a logger that is appropriate for the caller. See `Logger.log:forLevel:` for further documentation.
public func verbose<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
    Evergreen.log(message, error: error, forLevel: .Verbose, function: function, file: file, line: line)
}
/// Logs the event with the Debug log level using a logger that is appropriate for the caller. See `Logger.log:forLevel:` for further documentation.
public func debug<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
    Evergreen.log(message, error: error, forLevel: .Debug, function: function, file: file, line: line)
}
/// Logs the event with the Info log level using a logger that is appropriate for the caller. See `Logger.log:forLevel:` for further documentation.
public func info<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
    Evergreen.log(message, error: error, forLevel: .Info, function: function, file: file, line: line)
}
/// Logs the event with the Warning log level using a logger that is appropriate for the caller. See `Logger.log:forLevel:` for further documentation.
public func warning<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
    Evergreen.log(message, error: error, forLevel: .Warning, function: function, file: file, line: line)
}
/// Logs the event with the Error log level using a logger that is appropriate for the caller. See `Logger.log:forLevel:` for further documentation.
public func error<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
    Evergreen.log(message, error: error, forLevel: .Error, function: function, file: file, line: line)
}
/// Logs the event with the Critical log level using a logger that is appropriate for the caller. See `Logger.log:forLevel:` for further documentation.
public func critical<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
    Evergreen.log(message, error: error, forLevel: .Critical, function: function, file: file, line: line)
}

/// Reads the logging configuration from environment variables. Every environment variable with prefix 'Evergreen' is evaluated as a logger key path and assigned a log level corresponding to its value. Values should match the log level descriptions, e.g. 'Debug'. Valid environment variable declarations would be e.g. 'Evergreen = Debug' or 'Evergreen.MyLogger = Verbose'.
public func configureFromEnvironment()
{
    let prefix = "Evergreen"
    let environmentVariables = NSProcessInfo.processInfo().environment
    var configurations = [(Logger, LogLevel)]()
    for (key, value) in environmentVariables where key.hasPrefix(prefix) {
        let (_, keyPath) = Logger.KeyPath(string: key).popFirst()
        let logger = Logger.loggerForKeyPath(keyPath)
        if let logLevel = LogLevel(description: value) {
            logger.logLevel = logLevel
            configurations.append((logger, logLevel))
        } else {
            log("Invalid Evergreen log level '\(value)' for key path '\(keyPath)' in environment variable.", forLevel: .Warning)
        }
    }
    if configurations.count > 0 {
        log("Configured Evergreen logging from environment. Configurations: \(configurations)", forLevel: .Debug)
    } else {
        log("Tried to configure Evergreen logging from environment, but no valid configuration was found.", forLevel: .Warning)
    }
}


// MARK: - Logger

public final class Logger {
    
    
    // MARK: Public Properties

    /// A logger will only log events with equal or higher log levels. If no log level is specified, the `effectiveLogLevel` is used to determine the log level by reaching up the logger hierarchy until a logger specifies a log level.
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
    /// The children in the logger hierarchy
    public private(set) var children = [ String : Logger]()
    /// The root of the logger hierarchy
    public var root: Logger {
        if let parent = parent {
            return parent.root
        } else {
            return self
        }
    }
    
    /// The key used to identify this logger in the logger hierarchy and in records emitted by a handler
    public let key: String
    /// The key path up to the root of the logger hierarchy
    public var keyPath: KeyPath {
        return self.keyPath()
    }
    /// The key path up to (excluding) any logger in the hierarchy or to the root, if none is specified
    public func keyPath(upToParent excludedLogger: Logger? = nil) -> KeyPath {
        if let parent = self.parent where !(excludedLogger != nil && parent === excludedLogger!) {
            return parent.keyPath(upToParent: excludedLogger).keyPathByAppendingComponent(self.key)
        } else {
            return KeyPath(components: [ self.key ])
        }
    }


    // MARK: Initialization
    
    /// Creates a new logger. If you don't specify a parent, the logger is detached from the logger hierarchy and will not have any handlers. For general purposes, use the global getLogger method or the various Logger class and instance methods instead to retrieve appropriate loggers in the logger hierarchy.
    public init(key: String, parent: Logger?) {
        self.key = key
        self.parent = parent
        parent?.children[key] = self
    }


    // MARK: Intial Info
    
    private var hasLoggedInitialInfo: Bool = false
    /// Logs appropriate information about the logging setup automatically when the first logging call occurs.
    private func logInitialInfo() {
        if !hasLoggedInitialInfo {
            if handlers.count > 0 {
                let event = Event(logger: self, message: { "Logging to \(self.handlers)..." }, error: nil, logLevel: .Info, date: NSDate(), elapsedTime: nil, function: #function, file: #file, line: #line)
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
    
    /**
    Logs the event given by its `message` and additional information that is gathered automatically. The `logLevel` parameter in conjunction with the logger's `effectiveLogLevel` determines, if the event will be handled or ignored.
    
    - parameter message: The message to be logged, provided by an autoclosure. The closure will not be evaluated if the event is not going to be emitted, so it can contain expensive operations only needed for logging purposes.
    - parameter logLevel: If the event's log level is lower than the receiving logger's `effectiveLogLevel`, the event will not be logged. The event will always be logged, if no log level is provided for either the event or the logger's `effectiveLogLevel`.
    */
    public func log<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, forLevel logLevel: LogLevel? = nil, function: String = #function, file: String = #file, line: Int = #line)
    {
        let event = Event(logger: self, message: message, error: error, logLevel: logLevel, date: NSDate(), elapsedTime: nil, function: function, file: file, line: line)
        self.logEvent(event)
    }
    
    /// Logs the event with the Verbose log level. See `log:forLevel:` for further documentation.
    public func verbose<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
        self.log(message, error: error, forLevel: .Verbose, function: function, file: file, line: line)
    }
    /// Logs the event with the Debug log level. See `log:forLevel:` for further documentation.
    public func debug<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
        self.log(message, error: error, forLevel: .Debug, function: function, file: file, line: line)
    }
    /// Logs the event with the Info log level. See `log:forLevel:` for further documentation.
    public func info<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
        self.log(message, error: error, forLevel: .Info, function: function, file: file, line: line)
    }
    /// Logs the event with the Warning log level. See `log:forLevel:` for further documentation.
    public func warning<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
        self.log(message, error: error, forLevel: .Warning, function: function, file: file, line: line)
    }
    /// Logs the event with the Error log level. See `log:forLevel:` for further documentation.
    public func error<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
        self.log(message, error: error, forLevel: .Error, function: function, file: file, line: line)
    }
    /// Logs the event with the Critical log level. See `log:forLevel:` for further documentation.
    public func critical<M>(@autoclosure(escaping) message: () -> M, error: ErrorType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
        self.log(message, error: error, forLevel: .Critical, function: function, file: file, line: line)
    }
    
    /// Logs the given event. Use `log:forLevel:` for convenience.
    public func logEvent<M>(event: Event<M>)
    {
        self.logInitialInfo()
        
        if let effectiveLogLevel = self.effectiveLogLevel, let eventLogLevel = event.logLevel where eventLogLevel < effectiveLogLevel {
            return
        } else {
            self.handleEvent(event)
        }
    }
    
    /// Passes the event to this logger's `handlers` and then up the logger hierarchy, given `shouldPropagate` is set to `true`.
    private func handleEvent<M>(event: Event<M>, wasHandled: Bool = false)
    {
        var wasHandled = wasHandled
        for handler in handlers {
            handler.emitEvent(event)
            wasHandled = true
        }
        if let parent = self.parent where shouldPropagate {
            parent.handleEvent(event, wasHandled: wasHandled)
        } else {
            if !wasHandled {
                // TODO: use println() directly? Using log() will cause an endless loop when defaultLogger does not have any handlers.
                print("Tried to log an event for logger '\(event.logger)', but no handler was found in the logger hierarchy to emit the event: \(event.file):\(event.line) \(event.function)")
            }
        }
    }
    
    
    // MARK: Measuring Time
    
    private var defaultStartDate: NSDate?
    private lazy var startDates = [String : NSDate]()
    
    // TODO: log "Tic..." message by default
    /**
    Log the given event and start tracking the time until the next call to `toc:`.

    - parameter message: The message to be logged, provided by an autoclosure for lazy evaluation (see `log:forLevel:`)
    - parameter logLevel: The event's log level (see `log:forLevel:`)
    - parameter timerKey: Provide as an identifier in nested calls to `tic:` and `toc:`.
    */
    public func tic<M>(@autoclosure(escaping) andLog message: () -> M, forLevel logLevel: LogLevel? = nil, timerKey: String? = nil, function: String = #function, file: String = #file, line: Int = #line)
    {
        if let timerKey = timerKey {
            startDates[timerKey] = NSDate()
        } else {
            defaultStartDate = NSDate()
        }
        self.log(message, forLevel: logLevel, function: function, file: file, line: line)
    }
    
    // TODO: log "...Toc" message by default
    /// When called after a preceding call to `tic:`, the elapsed time between both calls will be appended to the record. See `tic:` for documentation and usage of the `timerKey` parameter in nested calls to `tic:` and `toc:`.
    public func toc<M>(@autoclosure(escaping) andLog message: () -> M, forLevel logLevel: LogLevel? = nil, timerKey: String? = nil, function: String = #function, file: String = #file, line: Int = #line)
    {
        var startDate: NSDate?
        if let timerKey = timerKey {
            startDate = startDates[timerKey]
        } else {
            startDate = defaultStartDate
        }
        if let startDate = startDate {
            let elapsedTime = NSDate().timeIntervalSinceDate(startDate)
            let event = Event(logger: self, message: message, error: nil, logLevel: logLevel, date: NSDate(), elapsedTime: elapsedTime, function: function, file: file, line: line)
            self.logEvent(event)
        }
    }

    
    // MARK: Logger Hierarchy
    
    /// The root of the logger hierarchy
    public class func defaultLogger() -> Logger {
        return Evergreen.defaultLogger
    }
    
    /// Returns an appropriate logger for the given file. Generally, the logger's key will be the file name and it will be a direct child of the default logger.
    public class func loggerForFile(file: String = #file) -> Logger {
        guard let fileURL = NSURL(string: file), let key = fileURL.lastPathComponent else {
            return Evergreen.defaultLogger
        }
        return self.loggerForKeyPath(KeyPath(components: [ key ]))
    }
    
    /// Returns the logger for the specified key path. A key path is a dot-separated string of keys like `"MyModule.MyClass"` describing the logger hierarchy relative to the default logger. Always returns the same logger object for a given key path. A parent-children relationship is established and can be used to set specific settings like log levels and handlers for only parts of the logger hierarchy.
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

    /// Returns a logger with a given key path relative to the receiver.
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
    
    /// Encapsulates a hierarchical structure of keys used to identify a logger's position in the logger hierarchy.
    public struct KeyPath: StringLiteralConvertible, CustomStringConvertible {
        
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
        
        public func description(separator separator: String? = nil) -> String {
            return components.joinWithSeparator(separator ?? ".")
        }
    }

}


// MARK: - Printable

extension Logger: CustomStringConvertible {
    
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


// MARK: - Log Levels

/**
You can assign an *importance* or *severity* to an event corresponding to one of the following *log levels*:

- **Critical:** Events that are unexpected and can cause serious problems. You would want to be called in the middle of the night to deal with these.
- **Error:** Events that are unexpected and not handled by your software. Someone should tell you about these ASAP.
- **Warning:** Events that are unexpected, but will probably not affect the runtime of your software. You would want to investigate these eventually.
- **Info:** General events that document the software's lifecycle.
- **Debug:** Events to give you an understanding about the flow through your software, mainly for debugging purposes.
- **Verbose:** Detailed information about the environment to provide additional context when needed.

The logger that handles the event has a log level as well. **If the event's log level is lower than the logger's, it will not be logged.**

In addition to the log levels above, a logger can have one of the following log levels. Assigning these to events only makes sense in specific use cases.

- **All:** All events will be logged.
- **Off:** No events will be logged.
*/
public enum LogLevel: Int, CustomStringConvertible, Comparable {

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
    
    public init?(description: String) {
        let description = description.lowercaseString
        var i = 0
        while let logLevel = LogLevel(rawValue: i) {
            if logLevel.description.lowercaseString == description {
                self = logLevel
                return
            }
            i += 1
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

/// Represents an event given by a descriptive message and additional information that occured during the software's runtime. A log level describing the event's severity is associated with the event.
public struct Event<M> {
    
    /// The logger that originally logged the event
    let logger: Logger
    /// The log message
    let message: () -> M
    /// An error that occured alongside the event
    let error: ErrorType?
    /// The log level. A logger will only log events with equal or higher log levels than its own. Events that don't specify a log level will always be logged.
    let logLevel: LogLevel?
    let date: NSDate
    let elapsedTime: NSTimeInterval?
    
    let function: String
    let file: String
    let line: Int
    
}
