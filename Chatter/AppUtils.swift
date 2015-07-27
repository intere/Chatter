//
//  AppUtils.swift
//  Chatter
//
//  Created by Eric Internicola on 7/26/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit

class AppUtils {
    
    static func isUserListView(controller: UIViewController?) -> Bool {
        return controller is UsersViewController
    }
    
    static func isChatView(controller: UIViewController?) -> Bool {
        return controller is ChatViewController
    }
    
    static func getTopMostController() -> UIViewController {
        var topController = UIApplication.sharedApplication().keyWindow!.rootViewController! as UIViewController
        while( nil != topController.presentedViewController) {
            topController = topController.presentedViewController!
        }
        
        return topController
    }
}
