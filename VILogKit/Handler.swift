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
    
    var formatter: Formatter { get set }
    
    func emitRecord<M>(record: Record<M>)
    
}


// MARK: - Console Handler Class

public class ConsoleHandler: Handler {
    
    public lazy var formatter: Formatter = {
        let formatter = Formatter()
        formatter.dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        formatter.dateFormatter.timeStyle = .NoStyle
        return formatter
    }()
    
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


// TODO: File Handler Class
