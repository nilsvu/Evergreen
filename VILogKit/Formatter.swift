//
//  Formatter.swift
//  VILogKit
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
    
    public func stringFromRecord<M>(record: Record<M>) -> String
    {
        let date = dateFormatter.stringFromDate(record.date)
        let logger = record.logger.description
        let level = "[" + (record.logLevel?.description ?? "Unspecified").uppercaseString + "]"

        let function = record.function
        let file = record.file.lastPathComponent
        let line = String(record.line)
        
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
        string += "\(record.message)"
        
        if let elapsedTime = record.elapsedTime {
            string += " [ELAPSED TIME: \(elapsedTime)s]"
        }

        return string
    }
    
}
