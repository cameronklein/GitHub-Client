//
//  RepoTableViewController.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/20/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class RepoTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
  
  var networkController : NetworkController!
  var repos : [Repo]?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    networkController = NetworkController.sharedInstance
    
    networkController.fetchReposFromSearchTerm("Hello World", completionHandler: { (errorDescription, repos) -> (Void) in
      if errorDescription == nil {
        self.repos = repos
        self.tableView.reloadData()
      }
    })
    
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if repos != nil {
      return repos!.count
    } else {
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("REPO_CELL", forIndexPath: indexPath) as UITableViewCell
    
    let repo = repos![indexPath.row]
    
    cell.textLabel?.text = repo.name
    
    return cell
  }



}