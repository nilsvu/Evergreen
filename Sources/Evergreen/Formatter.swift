//
//  Formatter.swift
//  Evergreen
//
//  Created by Nils Fischer on 12.10.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import Foundation


public class Formatter {
    
    public let components: [Component]
    
    public init(components: [Component]) {
        self.components = components
    }
    
    public enum Style {
        case Default, Simple, Full
    }
    
    /// Creates a formatter from any of the predefined styles.
    public convenience init(style: Style) {
        let components: [Component]
        switch style {
        case .Default:
            components = [ .Text("["), .Logger, .Text("|"), .LogLevel, .Text("] "), .Message ]
        case .Simple:
            components = [ .Message ]
        case .Full:
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            components = [ .Date(formatter: dateFormatter), .Text(" ["), .Logger, .Text("|"), .LogLevel, .Text("] "), .Message ]
        }
        self.init(components: components)
    }
    
    public enum Component {
        case Text(String), Date(formatter: NSDateFormatter), Logger, LogLevel, Message, Function, File, Line//, Any(stringForEvent: (event: Event<M>) -> String)
        
        public func stringForEvent<M>(event: Event<M>) -> String {
            switch self {
            case .Text(let text):
                return text
            case .Date(let formatter):
                return formatter.stringFromDate(event.date)
            case .Logger:
                return event.logger.description
            case .LogLevel:
                return (event.logLevel?.description ?? "Unspecified").uppercaseString
            case .Message:
                switch event.message() {
                case let error as NSError:
                    return error.localizedDescription
                case let message:
                    return String(message)
                }
            case .Function:
                return event.function
            case .File:
                return event.file
            case .Line:
                return String(event.line)
            }
        }
    }
    
    /// Produces a record from a given event. The record can be subsequently emitted by a handler.
    public final func recordFromEvent<M>(event: Event<M>) -> Record {
        return Record(date: event.date, description: self.stringFromEvent(event))
    }
    
    public func stringFromEvent<M>(event: Event<M>) -> String
    {
        var string = components.map({ $0.stringForEvent(event) }).joinWithSeparator("")
        
        if let elapsedTime = event.elapsedTime {
            string += " [ELAPSED TIME: \(elapsedTime)s]"
        }
        
        if let error = event.error {
            let errorMessage: String
            switch error {
            case let error as CustomDebugStringConvertible:
                errorMessage = error.debugDescription
            case let error as CustomStringConvertible:
                errorMessage = error.description
            default:
                errorMessage = String(error)
            }
            string += " [ERROR: \(errorMessage)]"
        }
        
        if event.once {
            string += " [ONLY LOGGED ONCE]"
        }
        
        return string
    }
    
}
