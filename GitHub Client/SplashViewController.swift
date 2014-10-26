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
  
  func errorReceived(error: String) {
    let alert = UIAlertController(title: "OOPS!", message: error, preferredStyle: UIAlertControllerStyle.Alert)
    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
    alert.addAction(ok)
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    println("Screen Pressed!")
    networkController.requestOAuthAccess()
  }
  
  @IBAction func signInPressed(sender: AnyObject) {
    println("Sign In Button Pressed!")
    networkController.requestOAuthAccess()
  }
}