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
    
    self.navigationController?.title = "GitHub"
    
    networkController = NetworkController.sharedInstance
    
    networkController.fetchReposFromSearchTerm("Swift", completionHandler: { (errorDescription, repos) -> (Void) in
      if errorDescription == nil {
          self.repos = repos
          self.tableView.reloadData()
      } else {
        let alert = UIAlertController(title: "OOPS!", message: errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
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
    let cell = tableView.dequeueReusableCellWithIdentifier("REPO_CELL", forIndexPath: indexPath) as RepoCell
    
    let repo = repos![indexPath.row]
    
    cell.repoName.text = repo.name
    cell.ownerName.text = "By " + repo.owner
    cell.stars.text = repo.stars.description
    cell.watchers.text = repo.watchers.description
    cell.forks.text = repo.forks.description
    cell.descriptionLabel.text = repo.description
    
    cell.forkIcon.text = "\u{F020}"
    cell.starsIcon.text = "\u{F02A}"
    cell.watchersIcon.text = "\u{F04E}"
    
    cell.backgroundColor = UIColor(red: 114.0, green: 160.0, blue: 191.0, alpha: 1.0)
    
    return cell
  }



}