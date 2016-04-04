//
//  StenographyHandlerTestCase.swift
//  Evergreen
//
//  Created by Nils Fischer on 04.04.16.
//  Copyright © 2016 viWiD Webdesign & iOS Development. All rights reserved.
//

import Foundation
import XCTest
import Evergreen


class StenographyTestCase: XCTestCase {
    
    var stenographyHandler: StenographyHandler!
    var records: [Record] {
        return stenographyHandler.records
    }
    
    override func setUp() {
        super.setUp()
        stenographyHandler = StenographyHandler()
        Evergreen.defaultLogger.handlers = [ stenographyHandler ]
    }
    
}