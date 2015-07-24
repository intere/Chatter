//
//  ViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/18/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//


import UIKit
import Parse

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(ParseService.isLoggedIn()) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UsersViewController.loadMainChatViewControllerFromViewController(self)
            })            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

