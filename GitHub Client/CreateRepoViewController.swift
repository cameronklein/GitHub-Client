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
      

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  @IBAction func yesButtonPressed(sender: AnyObject) {
    
    let name = nameField.text
    let desc = descriptionField.text
    
    var dictionary = [String:String]()
    
    dictionary["name"] = name
    dictionary["description"] = description
    
    networkController.createRepo(dictionary, completionHandler: { (errorDescription, result) -> (Void) in
      if errorDescription != nil {
        println("Oops!")
      } else {
        println("Repo Created!")
      }
    })
    
  }
  
  @IBAction func noButtonPressed(sender: AnyObject) {
    
    
  }
  
  
  
  
  
  

}
