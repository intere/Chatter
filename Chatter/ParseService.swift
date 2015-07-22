//
//  ParseLogin.swift
//  Chatter
//
//  Created by Eric Internicola on 7/18/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import Foundation
import Parse

public class ParseService : NSObject {
    public static let sharedInstance = ParseService.new()
    public typealias BoolCompletionBlock = Optional<(Bool,NSError?)->Void>
    
    /** Constructor: Performs the initialization.  */
    override init() {
        super.init()
        initializeParseService()
    }
    
    /** Are we logged into Parse already?  */
    public static func isLoggedIn() -> Bool {
        return nil != PFUser.currentUser() && nil != PFUser.currentUser()!.objectId
    }
    
    /** Lets you create a login using the provided username, password, email, (optional) phone number and a callback block */
    public func registerLogin(username: String!, password: String!, email: String!, phoneNumber: String?, callback: (Bool, NSError?) -> Void) {
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
    public func login(username: String!, password: String!, callback: (PFUser?, NSError?) -> Void) {
        PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
            callback(user, error)
        }
    }
    
    /** Logs you out of the Parse Service.  */
    public func logout(callback: BoolCompletionBlock) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
            if nil != callback {
                callback!(nil == error, error)
            }
        }
    }
    
    /** Get the Authenticatd User.  */
    public func getAuthenticatedUser() -> PFUser? {
        return PFUser.currentUser()
    }
    
    /** Parse Service Initialization.  */
    public func initializeParseService() {
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()
        
        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        // ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
        Parse.setApplicationId("oo8ji6qUgdSCvEdDMOkjDC9whWGv0Tf7ue4znRvh", clientKey: "0MPYiKflidLWBdhbbfAvMCqJdV93Zupz5aQjVeOR")
    }
    
    /** Search for a user by username.  */
    public func findUser(username: String?, completion: ((NSArray?, NSError?) -> Void)) {
        let userQuery: PFQuery! = PFUser.query()
        userQuery.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
        
        userQuery.findObjectsInBackgroundWithBlock { objects, error in
            var contacts = [PFUser]()
            if (error == nil) {
                for user: PFUser in (objects as! [PFUser]) {
                    if nil == username || user.username!.rangeOfString(username!, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                        contacts.append(user)
                    }
                }
            }
            completion(contacts, error)
        }
    }
    
    /** The part of boostrapping that we need the application instance and launch options for:  */
    public func applicationLaunch(application: UIApplication!, launchOptions: [NSObject: AnyObject]?) {
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************
        
        PFUser.enableAutomaticUser()
        
        let defaultACL = PFACL();
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)
        
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        //
        // We only support iOS 8 and up (so we're using this API call for registering for notifications)
        //
        let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

    }
    
}