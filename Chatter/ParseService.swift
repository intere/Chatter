//
//  ParseLogin.swift
//  Chatter
//
//  Created by Eric Internicola on 7/18/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import Foundation
import Parse

class ParseService : NSObject {
    static let sharedInstance = ParseService.new()
    var authenticatedUser = nil as PFUser?
    
    /** Are we logged into Parse already?  */
    static func isLoggedIn() -> Bool {
        return nil != PFUser.currentUser()
    }
    
    /** Lets you create a login using the provided username, password, email, (optional) phone number and a callback block */
    func registerLogin(username: String!, password: String!, email: String!, phoneNumber: String?, callback: (Bool, NSError?) -> Void) {
        let user = PFUser()
        user.username = username
        user.password = password
        user.email = email
        
        if nil != phoneNumber {
            user["phone"] = phoneNumber
        }
        
        user.signUpInBackgroundWithBlock(callback)
    }
    
    /** Lets you login to Parse with the provided username and password.  */
    func login(username: String!, password: String!, callback: (PFUser?, NSError?) -> Void) {
        PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
            self.authenticatedUser = user
            callback(user, error)
        }
    }
    
    /** Get the Authenticatd User.  */
    func getAuthenticatedUser() -> PFUser? {
        return authenticatedUser
    }
    
    
}