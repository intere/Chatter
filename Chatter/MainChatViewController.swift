//
//  MainChatViewController.swift
//  Chatter
//
//  Created by Eric Internicola on 7/18/15.
//  Copyright (c) 2015 iColaSoft. All rights reserved.
//

import UIKit

class MainChatViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** Static Function to let you load this view controller from your view controller.  */
    static func loadMainChatViewControllerFromViewController(currentVc: UIViewController!) {
        let vc = currentVc.storyboard!.instantiateViewControllerWithIdentifier("MainChatViewController") as! MainChatViewController
        currentVc.presentViewController(vc, animated: true, completion: nil)
    }
}
