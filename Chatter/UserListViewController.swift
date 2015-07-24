//
//  UserListViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/19/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit

protocol UserSelectionListener {
    func userSelected(username: String!)
}

class UserListViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var users = []
    var selectionListenerDelegate = nil as UserSelectionListener?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "loadUsers", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        loadUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.textColor = UIColor.orangeColor()

        cell.textLabel!.text = users[indexPath.row].username

        return cell
    }
    
    func loadUsers() {
        self.refreshControl?.beginRefreshing()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
            ParseService.sharedInstance.findUser(nil) { (userList: NSArray?, error: NSError?) -> Void in
                if nil != userList {
                    self.users = userList!
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                        self.refreshControl!.endRefreshing()
                    })
                }
            }
        })
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let username = users[indexPath.row].username
        if nil != selectionListenerDelegate {
            selectionListenerDelegate!.userSelected(username)
        }
    }
}
