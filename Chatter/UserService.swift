//
//  UserService.swift
//  Chatter
//
//  Created by Eric Internicola on 7/26/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import Parse

public class UserService: NSObject {
    public static let sharedInstance = UserService()
    public var objectIdUserCache: [String: PFUser] = [:]
    public var usernameUserCache: [String: PFUser] = [:]
    private var populatedCache: Bool = false
    private var isPopulating: Bool = false
    private var populateOnce: dispatch_once_t = 0
    
    // MARK Query Methods
    public func queryForUserWithName(searchText: String, completion: ((NSArray?, NSError?) -> Void)) {
        let query: PFQuery! = PFUser.query()
        query.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
        
        query.findObjectsInBackgroundWithBlock { objects, error in
            var contacts = [PFUser]()
            if (error == nil) {
                for user: PFUser in (objects as! [PFUser]) {
                    if user.username!.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                        contacts.append(user)
                    }
                }
            }
            completion(contacts, error)
        }
    }
    
    /** Builds the User Caches.  */
    public func buildUserCache() -> Void {
        dispatch_once(&populateOnce, {
            self.isPopulating = true
            UserService.sharedInstance.queryForAllUsersWithCompletion({ (users: NSArray?, error: NSError?) -> Void in
                if nil == error {
                    for user in users as! [PFUser] {
                        UserService.sharedInstance.cacheUserIfNeeded(user)
                    }
                    
                    self.populatedCache = true
                    self.isPopulating = false
                    println("User Cache is populated: \(UserService.sharedInstance.usernameUserCache.count) users cached")
                } else {
                    println("Error building user cache: \(error!.localizedDescription)")
                }
            })
        })
    }
    
    public func queryForAllUsersWithCompletion(completion: ((NSArray?, NSError?) -> Void)?) {
        let query: PFQuery! = PFUser.query()
        query.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
        query.findObjectsInBackgroundWithBlock { objects, error in
            if let callback = completion {
                callback(objects, error)
            }
        }
    }
    
    public func queryAndCacheUsersWithIDs(userIDs: [String], completion: ((NSArray?, NSError?) -> Void)?) {
        let query: PFQuery! = PFUser.query()
        query.whereKey("objectId", containedIn: userIDs)
        query.findObjectsInBackgroundWithBlock { objects, error in
            if (error == nil) {
                for user: PFUser in (objects as! [PFUser]) {
                    self.cacheUserIfNeeded(user)
                }
            }
            if let callback = completion {
                callback(objects, error)
            }
        }
    }
    
    /** Use this method to get a user by either the username or the user id.  */
    public func cachedUserForUserIdOrusername(userIdOrUsername: String) -> PFUser? {
        if self.isCachePopulated() {
            var user = cachedUserForUsername(userIdOrUsername)
            if nil == user {
                user = cachedUserForUserID(userIdOrUsername)
            }
            return user
        } else {
            println("Error: User Cache is not yet populated")
            return nil
        }
    }
    
    /** Get a Cached User by its ObjectId.  */
    public func cachedUserForUserID(userId: String) -> PFUser? {
        if nil != objectIdUserCache[userId] {
            return objectIdUserCache[userId]
        }
        return nil
    }
    
    /** Get a Cached User by its username.  */
    public func cachedUserForUsername(username: String) -> PFUser? {
        if nil != usernameUserCache[username] {
            return usernameUserCache[username]
        }
        return nil
    }
    
    /** Add a User to the caches if its not yet cached.  */
    public func cacheUserIfNeeded(user: PFUser) {
        if nil == objectIdUserCache[user.objectId!] {
            objectIdUserCache[user.objectId!] = user
            usernameUserCache[user.username!] = user
        }
    }
    
    /** Have we populated the cache yet?  */
    public func isCachePopulated() -> Bool {
        return self.populatedCache
    }
    
    /** Is the cache currently in the state of populating?  */
    public func isCachePopulating() -> Bool {
        return self.isPopulating
    }
}
