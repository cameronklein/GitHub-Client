//
//  CreateRepoViewController.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/24/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class CreateRepoViewController: UIViewController {

  @IBOutlet weak var descriptionField: UITextView!
  @IBOutlet weak var nameField: UITextField!
  
  var networkController = NetworkController.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
      
  }

  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    descriptionField.resignFirstResponder()
    nameField.resignFirstResponder()
  }

  @IBAction func yesButtonPressed(sender: AnyObject) {
    descriptionField.resignFirstResponder()
    nameField.resignFirstResponder()
    let name = nameField.text
    let desc = descriptionField.text
    var dictionary = [String:String]()
    dictionary["name"] = name
    dictionary["description"] = desc
    networkController.createRepo(dictionary, completionHandler: { (errorDescription, result) -> (Void) in
      if errorDescription != nil {
        let alert = UIAlertController(title: "OOPS!", message: errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
      } else {
        println("Repo Created!")
        UIView.animateWithDuration(0.2, animations: { () -> Void in
          self.view.alpha = 0.0
        }, completion: { (success) -> Void in
          self.view.removeFromSuperview()
        })
        let parent = self.parentViewController as CurrentUserViewController
          parent.repoAdded(result!)
        
        
        
      }
    })
  }
  
  
  
}
