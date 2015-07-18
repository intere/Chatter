//
//  RegisterViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/18/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var usernameText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var phoneText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameText.delegate = self
        passwordText.delegate = self
        emailText.delegate = self
        phoneText.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func registerClicked(sender: UIButton) {
        if(validateUserRegistration()) {
            ParseService.sharedInstance.registerLogin(usernameText.text, password: passwordText.text, email: emailText.text, phoneNumber: phoneText.text, callback: {(success: Bool, error: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.handleLoginResult(success, error: error)
                })
            })
        } else {
            displayRegistrationError("Missing Required Information (username, password and email are all required)")
        }
    }
    
    /** Has the user provided all of the necessary login information?  */
    func validateUserRegistration() -> Bool {
        return !usernameText.text.isEmpty && !passwordText.text.isEmpty && !emailText.text.isEmpty
    }
    
    /** Handle a Registration callback.  */
    func handleLoginResult(success: Bool, error: NSError?) {
        if nil == error {
            if(success) {
                MainChatViewController.loadMainChatViewControllerFromViewController(self)
            } else {
                displayRegistrationError("Unknown Error")
            }
        } else {
            displayRegistrationError(error!.localizedDescription)
        }
    }
    
    /** Display a registration error to the user.  */
    func displayRegistrationError(errorDescription: String!) {
        var alert = UIAlertController(title: "Registration Error", message: "There was an error registering the username '" + usernameText.text + "': " + errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Error", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
