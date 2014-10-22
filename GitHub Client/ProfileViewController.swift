//
//  ProfileViewController.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/22/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController/*, UITableViewDataSource, UITableViewDelegate*/ {
  
  @IBOutlet weak var avatarImage: UIImageView!
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var currentUser : User?
  var networkController = NetworkController.sharedInstance
  

  override func viewDidLoad() {
    super.viewDidLoad()
    networkController.getCurrentUser { (errorDescription, result) -> (Void) in
      if errorDescription == nil {
        self.currentUser = result!
        
      } else {
        let alert = UIAlertController(title: "OOPS!", message: errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
      }
    }
  }
  
  
  
  
}
