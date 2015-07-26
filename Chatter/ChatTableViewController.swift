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
    var messages: Array<LYRMessage> = []
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
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func loadMessages() {
        self.refreshControl?.beginRefreshing()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
            let userId: String? = self.getUserIdForUsername(self.username!)
            if nil != userId {
                self.messages = LayerService.sharedInstance.loadMessages(userId!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                })
            } else {
                println("Error converting username to user id for user: \(self.username!)")
            }
        })
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        var message: LYRMessage = self.messages[indexPath.row]
        if message.sender.userID == self.username {
            cell = tableView.dequeueReusableCellWithIdentifier("ReceivedTextIdentifier", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.textColor = UIColor.blueColor()
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("SentTextIdentifier", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.textColor = UIColor.orangeColor()
        }
        cell.textLabel?.text = message.description
        
        return cell
    }
    
    func getUserIdForUsername(username: String) -> String? {
        var user: PFUser? = UserService.sharedInstance.cachedUserForUsername(username)
        if nil != user {
            return user?.objectId
        }
        return nil
    }

}
