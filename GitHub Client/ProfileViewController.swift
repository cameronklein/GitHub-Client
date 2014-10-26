//
//  ProfileViewController.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/22/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit
import WebKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var avatarImage: UIImageView!
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var bioLabel: UILabel!
  
  var currentUser : User?
  var networkController = NetworkController.sharedInstance
  var imageQueue = NSOperationQueue()
  var backingArray : [AnyObject]?
  var wantedUserName : String?

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNib(UINib(nibName: "RepoCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "REPO_CELL")
    userName.text = nil
    bioLabel.text = nil
    
    
    networkController.getUser(username: wantedUserName, completionHandler: { (errorDescription, result) -> (Void) in
      println(self.wantedUserName)
      if errorDescription == nil {
        self.doSearch()
        self.currentUser = result!
        self.userName.text = self.currentUser!.name
        self.bioLabel.text = self.currentUser!.location
        self.networkController.fetchImageFromURL(self.currentUser!.avatarURL, completionHandler: { (image) -> Void in
          self.avatarImage.image = image
        })
      } else {
        let alert = UIAlertController(title: "OOPS!", message: errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
      }
    })
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if backingArray != nil{
      println(backingArray!.count)
      return backingArray!.count
    } else {
    return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let object : AnyObject = backingArray![indexPath.row]
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
      networkController.fetchImageFromURL(currentUser!.avatarURL, completionHandler: { (image) -> Void in
        cell.avatarImage.image = image
      })
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 200
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let object : AnyObject = backingArray![indexPath.row]
    if let repo = object as? Repo {
      let vc = UIViewController()
      let webview = WKWebView()
      let url = NSURL(string: repo.url)
      webview.loadRequest(NSURLRequest(URL: url!))
      vc.navigationItem.title = "Web View"
      vc.view.addSubview(webview)
      if let nav = self.navigationController {
        nav.pushViewController(vc, animated: true)
      } else {
        self.splitViewController?.showDetailViewController(vc, sender: self)
      }
      webview.bounds = vc.view.frame
      webview.frame  = vc.view.frame
    }
  }
  
  func doSearch() {
    networkController.fetchUserRepos(username: wantedUserName, completionHandler: { (errorDescription, result) -> (Void) in
      if errorDescription == nil {
        self.backingArray = result
        self.tableView.reloadData()
      } else {
        let alert = UIAlertController(title: "OOPS!", message: errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
      }
      
    
    })
  }
}
