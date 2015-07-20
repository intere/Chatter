//
//  LayerService.swift
//  Chatter
//
//  Created by Eric Internicola on 7/18/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import LayerKit
import Parse

public class LayerService: NSObject {
    public static let sharedInstance = LayerService.new()
    var layerClient: LYRClient?
    var conversation: LYRConversation?
    public typealias BoolCompletionBlock = Optional<(Bool,NSError?)->Void>
    public typealias StringCompletionBlock = Optional<(String?,NSError?)->Void>
    
    /** Constructor, initializes the LayerKit Framework.  */
    override init() {
        super.init()
    }
    
    /** The part of boostrapping that we need the application instance and launch options for:  */
    func applicationLaunch(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        // TODO - do we need to do anything?
    }
    
    func sendMessage(messageText: String!) {
        // If no conversations exist, create a new conversation object with two participants
        // For the purposes of this Quick Start project, the 3 participants in this conversation are 'Device'  (the authenticated user id), 'Simulator', and 'Dashboard'.
        if nil == self.conversation {
            var error: NSError?
            self.conversation = layerClient?.newConversationWithParticipants(["Simulator", "Dashboard"], options: nil, error: &error)
            if nil == self.conversation {
                println("New Conversation creation failed: " + error!.localizedDescription)
                return
            }
        }
        
        // Creates a message part with text/plain MIME Type
        let messagePart = LYRMessagePart(text: messageText)
        
        // Creates and returns a new message object with the given conversation and array of message parts
        let message = self.layerClient?.newMessageWithParts([messagePart], options: [LYRMessageOptionsPushNotificationAlertKey: messageText], error: nil) as LYRMessage!
        
        // Sends the specified message
        var error: NSError?
        let success = self.conversation!.sendMessage(message, error:&error)
        if success {
            println("Message queued to be sent: " + messageText)
        } else {
            println("Message send failed: " + error!.localizedDescription)
        }
    }
    
    /** This method handles logging into the Layer Service.  */
    public func connect(completion: BoolCompletionBlock) {
        layerClient = LYRClient(appID: NSURL(string: "layer:///apps/staging/0c3563da-2d71-11e5-a6d7-42908f007550"))
        layerClient?.connectWithCompletion({ (success: Bool, error: NSError?) -> Void in
            if(success) {
                println("Connected to Layer Service")
                if nil != PFUser.currentUser()!.objectId {
                    let userID = PFUser.currentUser()!.objectId! as String
                    self.authenticateLayerWithUserID(userID, completion: completion)
                } else {
                    self.layerClient = nil
                    println("We don't have the Parse User ID Yet, deferring for a second")
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_MSEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                        self.connect(completion)
                    })
                }
            } else {
                println("Error connecting to Layer Service: " + error!.localizedDescription)
                if nil != completion {
                    completion!(false,error)
                }
            }
        })
    }
    
    /** This method disconnects from the Layer Service.  */
    public func disconnect(completion: BoolCompletionBlock) {
        let userId = PFUser.currentUser()!.objectId! as String
        
        layerClient!.deauthenticateWithCompletion({ (success:Bool, error: NSError?) -> Void in
            self.layerClient = nil
            if success {
                completion!(true,nil)
            } else {
                completion!(false,error)
            }
        })
    }
    
    /**
     * You must authenticate a user before they are allowed to send or receive messages. Layer
     * authentication requires that a backend server generate an Identity Token on behalf of the 
     * client. For testing purposes, Layer provides a sample backend that takes care of this. 
     *
     * Note: You cannot use this sample backend with Production App IDs.  Layer will cache 
     * authentication details so you only need authenticate users if you de-authenticate the 
     * current user (when a user logs out for example) or receive an authentication challenge. 
     * The code below adds a check on login for authenticated users sessions.
     */
    func authenticateLayerWithUserID(userId: String, completion:BoolCompletionBlock) {
        if nil != layerClient?.authenticatedUserID {
            if userId == layerClient?.authenticatedUserID {
                println("Layer Authenticated as User: " + layerClient!.authenticatedUserID!)
                if nil != completion {
                    completion!(true,nil)
                }
            } else {
                layerClient!.deauthenticateWithCompletion({ (success:Bool, error: NSError?) -> Void in
                    if success {
                        self.layerClient!.authenticateWithIdentityToken(userId, completion: { (userId:String?, error:NSError?) -> Void in
                            if nil != completion {
                                if nil != userId {
                                    completion!(true,nil)
                                } else {
                                    completion!(false,error)
                                }
                            }
                        })
                    } else {
                        completion!(false,error)
                    }
                })
            }
        } else {
            self.authenticationTokenWithUserId(userId, completion: { (success: Bool, error: NSError?) -> Void in
                if nil != completion {
                    completion!(success,error)
                }
            })
        }
    }
    
    /**
     *
     */
    func authenticationTokenWithUserId(userId: String, completion:BoolCompletionBlock) {
        // 1. Request an authentication Nonce from Layer
        layerClient!.requestAuthenticationNonceWithCompletion({ (nonce, error) -> Void in
            if nil == nonce {
                if nil != completion {
                    completion!(false,error!)
                }
                return
            }
            let appString = self.layerClient?.appID.absoluteString
            
            // 2. Acquire identity Token from Layer Identity Service
            PFCloud.callFunctionInBackground("generateToken", withParameters: ["nonce": nonce, "userID": userId]) { (object:AnyObject?, error: NSError?) -> Void in
                if nil == error {
                    let identityToken = object as! String
                    self.layerClient!.authenticateWithIdentityToken(identityToken) { authenticatedUserID, error in
                        if (!authenticatedUserID.isEmpty) {
                            if nil != completion {
                                completion!(true, nil)
                            }
                            println("Layer Authenticated as User: \(authenticatedUserID)")
                        } else {
                            completion!(false, error)
                        }
                    }
                } else {
                    println("Parse Cloud function failed to be called to generate token with error: \(error)")
                }
            }
            
        })
    }
}
