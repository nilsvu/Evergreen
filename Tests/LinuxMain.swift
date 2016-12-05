import XCTest
@testable import EvergreenTests

XCTMain([
    testCase(LoggerTests.allTests),
    testCase(LoggingTests.allTests),
])
