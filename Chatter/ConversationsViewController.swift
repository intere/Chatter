//
//  ConversationsViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/23/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import Parse

class ConversationsViewController: UIViewController, UserSelectionListener {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedConversationTableViewController" {
            let conversationListVc = segue.destinationViewController as! ConversationTableViewController
            conversationListVc.selectionListenerDelegate = self
        }
    }
    
    func userSelected(username: String!) {
        ParseService.sharedInstance.findUser(username, completion: { (results: NSArray?, error) -> Void in
            if nil == error {
                if nil != results && results!.count > 0 {
                    if results!.count == 1 {
                        let found = results!.objectAtIndex(0) as! PFUser
                        println("Found User: " + found.username!)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.loadChatView(found)
                        })
                    }
                }
            }
        })
    }
    
    /** Open the Chat Window.  */
    func loadChatView(user: PFUser!) {
        let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        chatVc.setCurrentUser(user)
        self.presentViewController(chatVc, animated: true, completion: nil)
    }
}
