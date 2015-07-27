//
//  ChatTableViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/19/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import Parse
import LayerKit

class ChatTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    var layerMessages: Array<LYRMessage> = []
    var messages: Array<Message> = []
    var username: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "loadMessages", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func addMessage(messageText: String, sent: Bool) {
        if sent {
            self.messages.append(Message(message: messageText))
        } else {
            self.messages.append(Message(message: messageText, andSender: self.username))
        }
        self.tableView.reloadData()
        self.scrollToBottom()
    }
    
    func loadMessages() {
        self.refreshControl?.beginRefreshing()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
            let userId: String? = self.getUserIdForUsername(self.username!)
            if nil != userId {
                self.setMessagesFromApi(LayerService.sharedInstance.loadMessages(userId!))
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.scrollToBottom()
                })
            } else {
                println("Error converting username to user id for user: \(self.username!)")
            }
        })
    }
    
    func setMessagesFromApi(apiMessages: [LYRMessage]) {
        self.layerMessages = apiMessages
        self.messages = []
        for message: LYRMessage in self.layerMessages {
            let messageText: String = messageToString(message)!
            if message.sender.userID == PFUser.currentUser()?.objectId {
                self.messages.append(Message(message: messageText))
            } else {
                self.messages.append(Message(message: messageText, andSender: self.username))
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        var message: Message = self.messages[indexPath.row]
        if message.sent {
            cell = tableView.dequeueReusableCellWithIdentifier("SentTextIdentifier", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.textColor = UIColor.blueColor()
            cell.textLabel?.textAlignment = NSTextAlignment.Right
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("ReceivedTextIdentifier", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.textColor = UIColor.orangeColor()
            cell.textLabel?.textAlignment = NSTextAlignment.Left
        }
        cell.textLabel?.text = message.messageText
        
        return cell
    }
    
    func messageToString(message: LYRMessage) -> String? {
        var string: String! = ""
        
        for part: LYRMessagePart in message.parts as! [LYRMessagePart] {
            if !string.isEmpty {
                string = "\n"
            }
            var appendString: String! = NSString(data: part.data, encoding: NSUTF8StringEncoding) as! String
            string = string + appendString
        }
        
        return string
    }
    
    func getUserIdForUsername(username: String) -> String? {
        var user: PFUser? = UserService.sharedInstance.cachedUserForUsername(username)
        if nil != user {
            return user?.objectId
        }
        return nil
    }
    
    func scrollToBottom() {
        dispatch_async(dispatch_get_main_queue(), {
            var indexPath: NSIndexPath = NSIndexPath(forRow: self.messages.count-1, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        })
    }
}
