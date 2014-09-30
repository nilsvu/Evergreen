//
//  VILogger.swift
//  VIOSFramework
//
//  Created by Nils Fischer on 19.08.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

// TODO: add support for Handlers and Formatters


import Foundation


public func log<T>(message: T, forLevel logLevel: VILogger.LogLevel = .Unspecified, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
    // TODO: filename processing.. there has to be a better way
    var filenameComponents = file.lastPathComponent.componentsSeparatedByString(".")
    VILogger.loggerForKeyPath(filenameComponents[0]).log(message, forLevel: logLevel, function: function, file: file, line: line)
}


private let _defaultLogger = VILogger(key: "Default")

public final class VILogger {
    
    
    // MARK: Public Properties

    public var logLevel: LogLevel = .Unspecified
    public var effectiveLogLevel: LogLevel {
        if logLevel != .Unspecified || parent == nil {
            return logLevel
        } else {
            return parent!.logLevel
        }
    }

    public let parent: VILogger?
    private var children = [ String : VILogger]()
    public let key: String


    // MARK: Initialization
    
    public init(key: String, parent: VILogger) {
        self.key = key
        self.parent = parent
        parent.children[key.lowercaseString] = self
    }

    private init(key: String) {
        self.key = key
    }

    
    // MARK: Logging

    // TODO: use DebugPrintable
    public func log<T>(message: T, forLevel logLevel: LogLevel = .Unspecified, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__)
    {
        if logLevel != .Unspecified {
            if logLevel < self.effectiveLogLevel {
                return
            }
        }
        println("\(self):\(logLevel.description.uppercaseString): \(message)")
    }
    // TODO: expose this API, maybe instead of global log function?
    /*
    public class func log<T>(message: T, forLevel logLevel: LogLevel = .Unspecified, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__)
    {
        self.defaultLogger().log(message, forLevel: logLevel, function: function, file: file, line: line)
    }*/
    

    // MARK: Logger Hierarchy
    
    public class func defaultLogger() -> VILogger {
        return _defaultLogger
    }

    public class func loggerForKeyPath(keyPath: String) -> VILogger {
        let components = keyPath.componentsSeparatedByString(".")
        var currentLogger = defaultLogger()
        for component in components {
            if component.lowercaseString == defaultLogger().key.lowercaseString {
                continue
            }
            if let componentLogger = currentLogger.children[component.lowercaseString] {
                currentLogger = componentLogger
            } else {
                currentLogger = VILogger(key: component, parent: currentLogger)
            }
        }
        return currentLogger
    }

}


// MARK: - Printable

extension VILogger: Printable {

    public var description: String {
        if parent == nil {
            return key
        } else {
            return parent!.description + "." + key
        }
    }

}


// MARK: - Log Level

extension VILogger {

    public enum LogLevel: Int, Printable, Comparable {

        case Unspecified = 0, Verbose, Debug, Info, Warning, Error, None

        public var description: String {
            switch self {
                case .Unspecified: return "Unspecified"
                case .Verbose: return "Verbose"
                case .Debug: return "Debug"
                case .Info: return "Info"
                case .Warning: return "Warning"
                case .Error: return "Error"
                case .None: return "None"
            }
        }
    }

}

public func == (lhs: VILogger.LogLevel, rhs: VILogger.LogLevel) -> Bool {
    return lhs.toRaw() == rhs.toRaw()
}

public func < (lhs: VILogger.LogLevel, rhs: VILogger.LogLevel) -> Bool {
    return lhs.toRaw() < rhs.toRaw()
}
