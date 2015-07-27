//
//  NotificationService.swift
//  Chatter
//
//  Created by Eric Internicola on 7/26/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import Parse

public class NotificationService: NSObject {
    public static let sharedInstance = NotificationService()
    
    public func handleNotification(userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult)->Void)?) {
        
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            PFPush.handlePush(userInfo)
        } else {
            println("New Notification Received: \(userInfo)")
            handleWindowUpdates(userInfo)
            if nil != completionHandler {
                completionHandler!(UIBackgroundFetchResult.NoData)
            }
        }
    }
    
    func handleWindowUpdates(userInfo: [NSObject : AnyObject]) {
        let controller: UIViewController? = AppUtils.getTopMostController()
        
        if nil == controller {
            println("Top Level Controller is nill, we've got big problems...")
            return
        }
        
        let conversationId: String? = userInfo["layer"]!["conversation_identifier"] as? String
        let conversationText: String? = userInfo["aps"]!["alert"] as? String
        
        if nil != conversationId {
            if AppUtils.isChatView(controller) {
                let chatView: ChatViewController = controller as! ChatViewController
                if chatView.isConversation(conversationId!) {
                    chatView.receivedMessage(conversationText)
                } else {
                    PFPush.handlePush(userInfo)
                }
            } else if AppUtils.isUserListView(controller) {
                let userListView: UsersViewController = controller as! UsersViewController
            }
        }
    }
}
