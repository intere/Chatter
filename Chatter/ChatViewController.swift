//
//  ChatViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/19/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import Parse
import LayerKit

class ChatViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var messageText: UITextField!
    var user: PFUser?
    var conversation: LYRConversation?
    var chatListVc: ChatTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedChatTableViewController" {
            chatListVc = segue.destinationViewController as! ChatTableViewController
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField === self.messageText {
            self.sendMessage()
        }
        return true
    }
    
    @IBAction func backButtonClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendMessage() {
        if !self.messageText.text.isEmpty {
            LayerService.sharedInstance.sendMessage(self.conversation!, messageText: self.messageText.text)
            self.messageText.text = ""
        }
    }
    
    func setCurrentUser(user: PFUser!) -> Void {
        if nil != usernameLabel {
            self.user = user
            self.usernameLabel.text = user.username
            self.conversation = LayerService.sharedInstance.createConversation(user.username)
            if nil != chatListVc {
                chatListVc!.username = user.username
                chatListVc!.loadMessages()
            }
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_MSEC))), dispatch_get_main_queue(), { () -> Void in
                self.setCurrentUser(user)
            })
        }
    }
}
