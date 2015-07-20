//
//  MainChatViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/18/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import Parse

class MainChatViewController: UIViewController {
    @IBOutlet var usernameText: UITextField!
    @IBOutlet var addUserChatButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /** Static Function to let you load this view controller from your view controller.  */
    static func loadMainChatViewControllerFromViewController(currentVc: UIViewController!) {
        loadMainChatViewControllerFromViewController(currentVc, dismissCurrentVc: false)
    }
    
    static func loadMainChatViewControllerFromViewController(currentVc: UIViewController!, dismissCurrentVc: Bool) {
        let vc = currentVc.storyboard!.instantiateViewControllerWithIdentifier("MainChatViewController") as! MainChatViewController

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
    
    
    @IBAction func addUserButtonClicked(sender: UIButton) {
        if !usernameText.text.isEmpty {
            let username = usernameText.text
            ParseService.sharedInstance.findUser(username, completion: { (results: NSArray?, error) -> Void in
                if nil == error {
                    if nil != results && results!.count > 0 {
                        if results!.count == 1 {
                            let found = results!.objectAtIndex(0) as! PFUser
                            println("Found User: " + found.username!)
                        } else {
                            let users = results as! [PFUser]
                            let usernames = users.map { $0.username }
                            let usernamesString = ",".join(usernames as! [String])
                            
                            self.displayLoginError("Search Error", errorMessage: "We found too many results for your search (please provide an exact username match): " + usernamesString)
                        }
                    } else {
                        self.displayLoginError("Search Error", errorMessage: "We did not find any users that had the username: '" + username + "'")
                    }
                } else {
                    
                }
            })
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
}
