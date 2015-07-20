//
//  LoginViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/18/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var usernameText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameText.delegate = self
        passwordText.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == passwordText && validateUserLogin() {
            loginClicked(loginButton)
        }
        return true
    }
    
    
    @IBAction func cancelClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func loginClicked(sender: UIButton) {
        if(validateUserLogin()) {
            ParseService.sharedInstance.login(usernameText.text, password: passwordText.text, callback: { (user: PFUser?, error: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.handleLoginCallback(user, error: error)
                })
            })
        } else {
            displayLoginError("Missing Required Information: You must provide a username and password to login")
        }
    }
    
    /** Handle the login callback.  */
    func handleLoginCallback(user: PFUser?, error: NSError?) -> Void {
        if nil == error {
            MainChatViewController.loadMainChatViewControllerFromViewController(self)
        } else {
            displayLoginError(error!.localizedDescription)
        }
    }
    
    /** Ensure the user has provided the required information.  */
    func validateUserLogin() -> Bool {
        return !usernameText.text.isEmpty && !passwordText.text.isEmpty
    }
    
    /** Display a login error to the user.  */
    func displayLoginError(errorDescription: String!) {
        var alert = UIAlertController(title: "Login Error", message: "There was an error logging in with username '" + usernameText.text + "': " + errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Error", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
