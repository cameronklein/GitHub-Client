//
//  ViewController.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/20/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class SplitContainerViewController: UIViewController, UISplitViewControllerDelegate {

  let networkController = NetworkController.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    let childVC = self.childViewControllers.first as UISplitViewController
    childVC.delegate = self
    
    dispatch_after(1, dispatch_get_main_queue(), {
      if NSUserDefaults.standardUserDefaults().objectForKey("OAuth") == nil {
       self.networkController.requestOAuthAccess()
      }
      
    })
  }
  
  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
    return true
  }
  
  
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }


}

