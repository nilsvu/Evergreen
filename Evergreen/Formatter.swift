//
//  Formatter.swift
//  Evergreen
//
//  Created by Nils Fischer on 12.10.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import Foundation

public class Formatter {
    
    // TODO: add more possibilities to customize
  
    public lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter
    }()
    
    public func stringFromEvent<M>(event: Event<M>) -> String
    {
        let date = dateFormatter.stringFromDate(event.date)
        let logger = event.keyPath.descriptionWithSeparator(".")
        let level = "[" + (event.logLevel?.description ?? "Unspecified").uppercaseString + "]"

        let function = event.function
        let file = event.file.lastPathComponent
        let line = String(event.line)
        
        let components = [date, level, logger]
        var string = ""
        for (i, component) in enumerate(components) {
            if !component.isEmpty {
                string += component
                if i < components.count - 1 {
                    string += " "
                }
            }
        }
    
        if !string.isEmpty {
            string += ": "
        }
        string += "\(event.message)"
        
        if let elapsedTime = event.elapsedTime {
            string += " [ELAPSED TIME: \(elapsedTime)s]"
        }

        return string
    }
    
}
