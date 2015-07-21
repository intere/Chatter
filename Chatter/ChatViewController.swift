//
//  ChatViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/19/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import Parse

class ChatViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var messageText: UITextField!
    var user: PFUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backButtonClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setCurrentUser(user: PFUser!) -> Void {
        if nil != usernameLabel {
            self.user = user
            usernameLabel.text = user.username
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_MSEC))), dispatch_get_main_queue(), { () -> Void in
                self.setCurrentUser(user)
            })
        }
    }
}
