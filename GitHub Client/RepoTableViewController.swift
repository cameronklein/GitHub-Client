//
//  RepoTableViewController.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/20/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class RepoTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
  
  var networkController : NetworkController!
  var backingArray : [AnyObject]?
  var currentScope: Scope = .Repos
  var refreshController : UIRefreshControl!
  var imageQueue = NSOperationQueue()
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageQueue = NSOperationQueue()
    setUpTableView()
    networkController = NetworkController.sharedInstance
  }
  
  //MARK: - TableViewDataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if backingArray != nil {
      return backingArray!.count
    } else {
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let object: AnyObject = backingArray![indexPath.row]
    
    if let repo = object as? Repo {
      let cell = tableView.dequeueReusableCellWithIdentifier("REPO_CELL", forIndexPath: indexPath) as RepoCell
      cell.avatarImage.image = nil
      cell.repoName.text = repo.name
      cell.ownerName.text = "By " + repo.owner
      cell.stars.text = repo.stars.description
      cell.watchers.text = repo.watchers.description
      cell.forks.text = repo.forks.description
      cell.descriptionLabel.text = repo.description
      cell.forkIcon.text = "\u{F020}"
      cell.starsIcon.text = "\u{F02A}"
      cell.watchersIcon.text = "\u{F04E}"
      self.imageQueue.addOperationWithBlock({ () -> Void in
        let url = NSURL(string: repo.avatarURL!)
        let data = NSData(contentsOfURL: url!)
        let image = UIImage(data: data!)
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          cell.avatarImage.image = image
        })
      })
      return cell
    }
    
    if let user = object as? User {
      let cell = tableView.dequeueReusableCellWithIdentifier("USER_CELL", forIndexPath: indexPath) as UserCell
      cell.avatarImage.image = nil
      cell.username.text = user.login
      self.imageQueue.addOperationWithBlock({ () -> Void in
        let url = NSURL(string: user.avatarURL!)
        let data = NSData(contentsOfURL: url!)
        let image = UIImage(data: data!)
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          cell.avatarImage.image = image
        })
      })
      return cell
    }
    return UITableViewCell()
  }
  
  
  func setUpTableView() {
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 150.0
  }
  
  func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    currentScope = Scope(rawValue: selectedScope)!
    if searchBar.text != nil{
      doSearch()
    }
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    doSearch()
    searchBar.resignFirstResponder()
  }
  
  func doSearch(){
    networkController.fetchReposFromSearchTerm(searchBar.text, type: currentScope, completionHandler: { (errorDescription, result) -> (Void) in
      if errorDescription == nil {
        self.backingArray = result
        self.tableView.reloadData()
        self.changeTitleTo("Showing results for \"\(self.searchBar.text)\"")
        
      } else {
        let alert = UIAlertController(title: "OOPS!", message: errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
      }
    })
  }
  
  func changeTitleTo(string : String){
    UIView.animateWithDuration(1.0, animations: { () -> Void in
      self.navigationItem.title = string
    })
  }
  

}

enum Scope : Int {
  case Repos = 0, Users, All
  
  func toString() -> String{
    switch self{
    case Repos:
      return "repositories"
    case Users:
      return "users"
    case All:
      return "all"
    }
  }
}