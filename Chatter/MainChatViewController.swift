//
//  MainChatViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/18/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit

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
        let vc = currentVc.storyboard!.instantiateViewControllerWithIdentifier("MainChatViewController") as! MainChatViewController
        currentVc.presentViewController(vc, animated: true, completion: nil)
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
        
    }
}
