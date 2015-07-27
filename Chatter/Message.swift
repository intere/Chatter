//
//  Message.swift
//  Chatter
//
//  Created by Eric Internicola on 7/26/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import Parse

public class Message: NSObject {
    public var messageText: String!
    public var senderUsername: String!
    public var sent: Bool
    
    init(message messageText: String!) {
        self.messageText = messageText
        self.senderUsername = PFUser.currentUser()?.username
        self.sent = true
    }
    
    init(message messageText: String!, andSender senderUsername: String!) {
        self.messageText = messageText
        self.senderUsername = senderUsername
        self.sent = false
    }
}
