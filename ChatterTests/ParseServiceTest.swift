//
//  ParseServiceTest.swift
//  Chatter
//
//  Created by Eric Internicola on 7/19/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import XCTest
import Chatter

class ParseServiceTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSharedInstance() {
        XCTAssertNotNil(ParseService.sharedInstance, "The Parse Service was nil")
    }
    
    func testLogin() {
        let username = "intere" as String
        let password = "eric" as String
        
        var expectation = self.expectationWithDescription("Login Block")
        
        if ParseService.isLoggedIn() {
            ParseService.sharedInstance.logout({ (success:Bool, error: NSError?) -> Void in
                ParseService.sharedInstance.login(username, password: password) { (user, error: NSError?) -> Void in
                    XCTAssertNotNil(user, "user was nil")
                    XCTAssertNil(error, "There was an error trying to login")
                    expectation.fulfill()
                }
            })
        } else {
            ParseService.sharedInstance.login(username, password: password) { (user, error: NSError?) -> Void in
                XCTAssertNotNil(user, "user was nil")
                XCTAssertNil(error, "There was an error trying to login")
                expectation.fulfill()
            }
        }
        
        
        self.waitForExpectationsWithTimeout(10.0, handler: { (error:NSError!) -> Void in
            if nil != error {
                XCTFail("ParseService never returned a valid value: \(error.localizedDescription)")
            }
        })
    }
}
