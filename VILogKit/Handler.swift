//
//  Handler.swift
//  VILogKit
//
//  Created by Nils Fischer on 12.10.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import Foundation


// MARK - Handler Protocol

public protocol Handler {
    
    var logLevel: LogLevel? { get set }
    var formatter: Formatter { get set }
    
    func emitRecord<M>(record: Record<M>)
    
}


// MARK: - Console Handler Class

public class ConsoleHandler: Handler {
    
    public var logLevel: LogLevel?

    public lazy var formatter: Formatter = {
        let formatter = Formatter()
        formatter.dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        formatter.dateFormatter.timeStyle = .NoStyle
        return formatter
    }()
    
    public init() {}
    
    public convenience init(formatter: Formatter) {
        self.init()
        self.formatter = formatter
    }
    
    public func emitRecord<M>(record: Record<M>)
    {
        // TODO: use debugPrintln?
        println(self.formatter.stringFromRecord(record))
    }
    
}


// MARK: - File Handler Class

public class FileHandler: Handler {
    
    public var logLevel: LogLevel?
    
    public lazy var formatter: Formatter = Formatter()
    
    private let file: NSFileHandle
    
    public init(fileURL: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        if let path = fileURL.filePathURL?.path {
            if fileManager.createFileAtPath(path, contents: nil, attributes: nil) {
                self.file = NSFileHandle(forWritingAtPath: path)
            } else {
                // TOOD
                self.file = NSFileHandle()
            }
        } else {
            // TODO
            self.file = NSFileHandle()
        }
    }

    public convenience init(fileURL: NSURL, formatter: Formatter) {
        self.init(fileURL: fileURL)
        self.formatter = formatter
    }
    
    public func emitRecord<M>(record: Record<M>) {
        if let recordData = (self.formatter.stringFromRecord(record) + "\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            self.file.writeData(recordData)
        } else {
            // TODO
        }
    }
    
}
