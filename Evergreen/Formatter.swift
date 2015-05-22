//
//  Formatter.swift
//  Evergreen
//
//  Created by Nils Fischer on 12.10.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import Foundation


public class Formatter {
    
    public lazy var components: [Component] = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return [ .Date(formatter: dateFormatter), .Text(" ["), .Logger, .Text("|"), .LogLevel, .Text("] "), .Message ]
    }()

    public init() {}
    
    public init(components: [Component]) {
        self.components = components
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
                return String(stringInterpolationSegment: event.message())
            case .Function:
                return event.function
            case .File:
                return event.file
            case .Line:
                return String(event.line)
            }
        }
    }
    
    public func stringFromEvent<M>(event: Event<M>) -> String
    {
        var string = "".join(components.map { $0.stringForEvent(event) })
        
        if let elapsedTime = event.elapsedTime {
            string += " [ELAPSED TIME: \(elapsedTime)s]"
        }

        return string
    }
    
    public func recordFromEvent<M>(event: Event<M>) -> Record {
        return Record(date: event.date, description: self.stringFromEvent(event))
    }
    
}
