//
//  SplashViewController.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/25/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

  var networkController = NetworkController.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  @IBAction func signInPressed(sender: AnyObject) {
    networkController.requestOAuthAccess()
  }
}