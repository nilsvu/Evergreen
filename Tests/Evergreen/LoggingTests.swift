//
//  LoggingTests.swift
//  Evergreen
//
//  Created by Nils Fischer on 04.04.16.
//  Copyright © 2016 viWiD Webdesign & iOS Development. All rights reserved.
//

import XCTest
@testable import Evergreen


class LoggingTests: StenographyTestCase {
    
    
    func testLogLevels() {
        var expectedRecordCount = 0
        let message = "message"
        log(message)
        expectedRecordCount = records.count // there may be application info logged at the beginning
        XCTAssertEqual(records.count, expectedRecordCount, "The expected record \(expectedRecordCount) count does not match the number of logged records \(records.count): \(records)")
        XCTAssert(records[expectedRecordCount - 1].description.containsString(message))
        // undefined
        log(message)
        expectedRecordCount += 1
        XCTAssertEqual(records.count, expectedRecordCount, "The expected record \(expectedRecordCount) count does not match the number of logged records \(records.count): \(records)")
        Evergreen.logLevel = .Debug
        log(message, forLevel: .Verbose)
        XCTAssertEqual(records.count, expectedRecordCount, "The expected record \(expectedRecordCount) count does not match the number of logged records \(records.count): \(records)")
        log(message, forLevel: .Debug)
        expectedRecordCount += 1
        XCTAssertEqual(records.count, expectedRecordCount, "The expected record \(expectedRecordCount) count does not match the number of logged records \(records.count): \(records)")
        log(message, forLevel: .Info)
        expectedRecordCount += 1
        XCTAssertEqual(records.count, expectedRecordCount, "The expected record \(expectedRecordCount) count does not match the number of logged records \(records.count): \(records)")
    }
    
    func testErrorLogging() {
        enum TestError: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
            case Failure
            var debugDescription: String { return "custom_debug_description" }
            var description: String { return "custom_description"}
        }
        let error = TestError.Failure
        Evergreen.log("Something failed", error: error)
        XCTAssert(records.count == 1)
        XCTAssert(records[0].description.containsString("custom_debug_description"), "Logged error does not contain the error's debug description, which should be prioritized over its description.")
    }
    
    func testTimeLogging() {
        let message = "message"
        tic(andLog: message)
        var expectedRecordCount = records.count // there may be application info logged at the beginning
        XCTAssertEqual(records.count, expectedRecordCount, "The expected record \(expectedRecordCount) count does not match the number of logged records \(records.count): \(records)")
        XCTAssert(records[expectedRecordCount - 1].description.containsString(message))
        toc(andLog: message)
        expectedRecordCount += 1
        XCTAssertEqual(records.count, expectedRecordCount, "The expected record \(expectedRecordCount) count does not match the number of logged records \(records.count): \(records)")
        XCTAssert(records[expectedRecordCount - 1].description.containsString(message))
        XCTAssert(records[expectedRecordCount - 1].description.containsString("TIME"))
    }
    
}
