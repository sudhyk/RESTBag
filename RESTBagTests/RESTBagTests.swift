//
//  RESTBagTests.swift
//  RESTBagTests
//  Created by Sudheendra Kaanugovi on 9/8/15.
//  Copyright (c) 2015 NSStack. All rights reserved.
//

import Foundation
import XCTest

class RESTBagTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRBag() {
        // This is an example of a functional test case.
        weak var expectation:XCTestExpectation?
        expectation = expectationWithDescription("Get Test")
        var errorObj: NSError?
        var restObj = RBag()

        restObj.makeAPIRequest(apiservice: "test", requestDictionary: nil) { (response, error) -> () in
            errorObj = error
            print(response)
            expectation?.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertNil(errorObj, "Error should be nil")
    }
    
}
