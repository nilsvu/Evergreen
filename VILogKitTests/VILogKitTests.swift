//
//  VILogKitTests.swift
//  VILogKitTests
//
//  Created by Nils Fischer on 30.09.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import XCTest

class VILogKitTests: XCTestCase {
    
    func testDefaultLoggerIdentity() {
        let defaultLogger = VILogger.defaultLogger()
        XCTAssert(defaultLogger === VILogger.defaultLogger(), "Subsequent default logger queries return different objects")
        XCTAssert(defaultLogger === VILogger.loggerForKeyPath(defaultLogger.key), "Key path query does not return default logger object")
        XCTAssert(defaultLogger === VILogger.loggerForKeyPath("Default"), "Query with key path string Default does not return default logger object")
    }
    
    func testHierarchy() {
        let defaultLogger = VILogger.defaultLogger()
        let parentLogger = VILogger.loggerForKeyPath("Parent")
        XCTAssert(parentLogger.parent === defaultLogger, "Top level logger is not a child of the default logger")
        defaultLogger.logLevel = .None
        XCTAssert(parentLogger.effectiveLogLevel == defaultLogger.logLevel, "Child logger with no explicit log level set does not inherit parent's log level")
        let childLogger = VILogger.loggerForKeyPath("Parent.Child")
        XCTAssert(childLogger.parent === parentLogger, "Child logger created by key path Parent.Child is not a child of Parent logger")
        XCTAssert(VILogger.loggerForKeyPath("parent.child") === childLogger, "Key path accessor is case sensitive")
    }
    
}
