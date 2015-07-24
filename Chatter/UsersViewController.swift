//
//  MainChatViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/18/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import Parse

class UsersViewController: UIViewController, UITextFieldDelegate, UserSelectionListener {
    @IBOutlet var usernameText: UITextField!
    @IBOutlet var addUserChatButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameText.delegate = self
        initializeLayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        addUserButtonClicked(addUserChatButton)
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "embedUserListViewController") {
            let userListVc = segue.destinationViewController as! UserListViewController
            userListVc.selectionListenerDelegate = self
        }
    }
    
    @IBAction func addUserButtonClicked(sender: UIButton) {
        if !usernameText.text.isEmpty {
            let username = usernameText.text
            searchForUser(username)
        }
    }
    
    @IBAction func logoutClicked(sender: UIButton) {
        LayerService.sharedInstance.disconnect { (success: Bool, error: NSError?) -> Void in
            if !success {
                println("There was an error logging out of the Layer Service: " + error!.localizedDescription)
            }
            
            ParseService.sharedInstance.logout({ (success, error) in
                if !success {
                    println("There was an error logging out of the Parse Service: " + error!.localizedDescription)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    @IBAction func userListClicked(sender: UIButton) {
        let conversationsVc = storyboard!.instantiateViewControllerWithIdentifier("ConversationsViewController") as! ConversationsViewController
        self.presentViewController(conversationsVc, animated: true, completion: nil)
    }
    
    //
    // MARK - UserSelectionListener method
    //
    func userSelected(username: String!) {
        searchForUser(username)
    }
    
    /** Static Function to let you load this view controller from your view controller.  */
    static func loadMainChatViewControllerFromViewController(currentVc: UIViewController!) {
        loadMainChatViewControllerFromViewController(currentVc, dismissCurrentVc: false)
    }
    
    static func loadMainChatViewControllerFromViewController(currentVc: UIViewController!, dismissCurrentVc: Bool) {
        let vc = currentVc.storyboard!.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersViewController

        if dismissCurrentVc {
            currentVc.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.loadMainChatViewControllerFromViewController(self.getTopMostController())
            })
        } else {
            currentVc.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func initializeLayer() {
        LayerService.sharedInstance.connect { (success: Bool, error: NSError?) -> Void in
            if success {
                println("We're logged in to Layer")
            } else {
                println("Failed to login to Layer")
            }
        }
    }
    
    func searchForUser(username: String!) {
        ParseService.sharedInstance.findUser(username, completion: { (results: NSArray?, error) -> Void in
            if nil == error {
                if nil != results && results!.count > 0 {
                    if results!.count == 1 {
                        let found = results!.objectAtIndex(0) as! PFUser
                        println("Found User: " + found.username!)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.loadChatView(found)
                            self.usernameText.text = ""
                        })
                    } else {
                        let users = results as! [PFUser]
                        let usernames = users.map { $0.username } as Array<String!>
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.displayLoginError("Search Error", errorMessage: "We found too many results for your search (please provide an exact username match): \(usernames)" )
                        })
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayLoginError("Search Error", errorMessage: "We did not find any users that had the username: '" + username + "'")
                    })
                }
            } else {
                println("Error searching for user \(username): \(error!.localizedDescription)")
            }
        })
    }
    
    static func getTopMostController() -> UIViewController {
        var topController = UIApplication.sharedApplication().keyWindow!.rootViewController! as UIViewController
        while( nil != topController.presentedViewController) {
            topController = topController.presentedViewController!
        }
        
        return topController
    }
    
    /** Display a login error to the user.  */
    func displayLoginError(errorTitle: String, errorMessage: String!) {
        var alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Error", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /** Open the Chat Window.  */
    func loadChatView(user: PFUser!) {
        let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        chatVc.setCurrentUser(user)
        
        self.presentViewController(chatVc, animated: true, completion: nil)
    }
}
