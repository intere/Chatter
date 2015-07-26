//
//  UserServiceTest.swift
//  Chatter
//
//  Created by Eric Internicola on 7/26/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import XCTest
import Chatter

class UserServiceTest: XCTestCase {

    override func setUp() {
        super.setUp()
        ParseService.sharedInstance.initializeParseService()
        ParseService.sharedInstance.applicationLaunch(UIApplication.sharedApplication(), launchOptions: [:])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetSharedInstance() {
        XCTAssertNotNil(UserService.sharedInstance, "Shared Instances is not available")
    }
    
    func testBuildCache() {
        UserService.sharedInstance.buildUserCache()
        XCTAssertNotNil(UserService.sharedInstance.objectIdUserCache, "Object ID User Cache was nil")
        XCTAssertNotNil(UserService.sharedInstance.usernameUserCache, "Username User Cache was nil")
        XCTAssertFalse(UserService.sharedInstance.isCachePopulating(), "The Cache is still populating")
        XCTAssertTrue(UserService.sharedInstance.isCachePopulated(), "The Cache isn't populated")
    }
    
    func testGetUserByUsername() {
        if !UserService.sharedInstance.isCachePopulated() {
            var count = 0
            UserService.sharedInstance.buildUserCache()
            while(count < 20 && !UserService.sharedInstance.isCachePopulated()) {
                NSThread.sleepForTimeInterval(0.1)
                ++count
            }
        }
        let username: String = "dude"
        var user = UserService.sharedInstance.cachedUserForUsername(username)
        XCTAssertNotNil(user, "Cached user (by username) was nil")
    }
}
