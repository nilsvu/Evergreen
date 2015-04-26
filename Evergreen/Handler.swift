//
//  Handler.swift
//  Evergreen
//
//  Created by Nils Fischer on 12.10.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import Foundation


// MARK: - Record

public struct Record: Printable {

    public let date: NSDate
    public let description: String
    
}


// MARK: - Handler

public class Handler {
    
    public var logLevel: LogLevel?
    public var formatter: Formatter = Formatter()
    
    public init() {}
    
    public convenience init(formatter: Formatter) {
        self.init()
        self.formatter = formatter
    }
    
    /// Called by a logger to handle an event. By default, the event's log level is checked against the handler's and the given formatter is used to obtain a record from the event. Subsequently, emitRecord is called to produce the output. In most cases, subclasses should override emitRecord instead and leave this method to its default implementation.
    public func emitEvent<M>(event: Event<M>) {
        if let handlerLogLevel = self.logLevel, let eventLogLevel = event.logLevel where eventLogLevel < handlerLogLevel {
            return
        } else {
            self.emitRecord(self.formatter.recordFromEvent(event))
        }
    }

    /// Called to actually produce some output from a record. Override this method to send the record to an output stream of your choice. The default implementation simply prints the record to the console.
    public func emitRecord(record: Record) {
        println(record)
    }
    
}


// MARK: - Console Handler Class

/// A handler that writes log records to the console.
public class ConsoleHandler: Handler {
    
    override public func emitRecord(record: Record) {
        // TODO: use debugPrintln?
        println(record)
    }
    
}


// MARK: - File Handler Class

/// A handler that writes log records to a file.
public class FileHandler: Handler, Printable {
    
    private let file: NSFileHandle
    private let fileURL: NSURL
    
    public init?(fileURL: NSURL) {
        self.fileURL = fileURL
        let fileManager = NSFileManager.defaultManager()
        if let path = fileURL.filePathURL?.path {
            if fileManager.createFileAtPath(path, contents: nil, attributes: nil) {
                if let file = NSFileHandle(forWritingAtPath: path) {
                    file.seekToEndOfFile()
                    self.file = file
                } else {
                    self.file = NSFileHandle() // TODO: remove
                    super.init()
                    return nil
                }
            } else {
                self.file = NSFileHandle() // TODO: remove
                super.init()
                return nil
            }
        } else {
            self.file = NSFileHandle() // TODO: remove
            super.init()
            return nil
        }
        super.init()
    }

    public convenience init?(fileURL: NSURL, formatter: Formatter) {
        self.init(fileURL: fileURL)
        self.formatter = formatter
    }
    
    override public func emitRecord(record: Record) {
        if let recordData = (record.description + "\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            self.file.writeData(recordData)
        } else {
            // TODO
        }
    }
    
    public var description: String {
        return "\(_stdlib_getDemangledTypeName(self))(\(fileURL))"
    }
    
}


// MARK: Stenography Handler

/// A handler that appends log records to an array.
public class StenographyHandler: Handler {
    
    // TODO: make sure there is no memory problem when this array becomes to large
    /// All records logged to this handler
    public private(set) var records: [Record] = []
    
    override public func emitRecord(record: Record) {
        self.records.append(record)
    }
    
}
