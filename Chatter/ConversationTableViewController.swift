//
//  ConversationTableViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/23/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import Parse
import LayerKit


class ConversationTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var conversations: NSOrderedSet?
    var selectionListenerDelegate = nil as UserSelectionListener?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "loadConversations", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        loadConversations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if nil != conversations {
            return conversations!.count
        }
        
        return 0
    }
    
    func loadConversations() {
        self.refreshControl?.beginRefreshing()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
            self.conversations = LayerService.sharedInstance.loadConversations()
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            })
        })        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationCellReuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
        let conversation = conversations?.objectAtIndex(indexPath.row) as? LYRConversation
        cell.textLabel?.textColor = UIColor.orangeColor()
        
        cell.textLabel?.text = LayerService.getUsernameFromConversation(conversation)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if nil != selectionListenerDelegate {
            let conversation = conversations?[indexPath.row] as? LYRConversation
            let username = LayerService.getUsernameFromConversation(conversation)
            if nil != username {
                selectionListenerDelegate!.userSelected(username)
            }
        }
    }
}
