//
//  VILogKitTests.swift
//  VILogKitTests
//
//  Created by Nils Fischer on 30.09.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import XCTest
import VILogKit

class VILogKitTests: XCTestCase {
    
    func testDefaultLoggerIdentity() {
        let defaultLogger = Logger.defaultLogger()
        println(defaultLogger.keyPath)
        XCTAssert(defaultLogger === Logger.defaultLogger(), "Subsequent default logger queries return different objects")
        XCTAssert(defaultLogger === Logger.loggerForKeyPath(defaultLogger.keyPath), "Key path query does not return default logger object")
        XCTAssert(defaultLogger === Logger.loggerForKeyPath("Default"), "Query with key path string Default does not return default logger object")
    }
    
    func testHierarchy() {
        let defaultLogger = Logger.defaultLogger()
        let parentLogger = Logger.loggerForKeyPath("Parent")
        XCTAssert(parentLogger.parent === defaultLogger, "Top level logger is not a child of the default logger")
        defaultLogger.logLevel = .None
        XCTAssert(parentLogger.effectiveLogLevel == defaultLogger.logLevel, "logger with no explicit log level does not inherit parent's log level")
        let childLogger = Logger.loggerForKeyPath("Parent.Child")
        XCTAssert(childLogger.parent === parentLogger, "Child logger created by key path Parent.Child is not a child of Parent logger")
    }
    
}
