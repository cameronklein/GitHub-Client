//
//  RepoTableViewController.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/20/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate {
  
  var networkController : NetworkController!
  var backingArray : [AnyObject]?
  var currentScope: Scope = .Repos
  var refreshController : UIRefreshControl!
  var imageQueue = NSOperationQueue()
  var selectedCell : UICollectionViewCell?
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  var collectionView : UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpTableView()
    
    self.navigationController?.delegate = self
    
    let layout = UICollectionViewFlowLayout()
    let screenWidth = self.view.frame.width
    layout.minimumLineSpacing = screenWidth * 0.03
    layout.minimumInteritemSpacing = screenWidth * 0.03
    layout.sectionInset.left = screenWidth * 0.03
    layout.sectionInset.right = screenWidth * 0.03
    layout.sectionInset.top = screenWidth * 0.03
    layout.itemSize = CGSize(width: screenWidth * 0.29, height: screenWidth * 0.34)
    collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), collectionViewLayout: layout)
    collectionView.registerNib(UINib(nibName: "UserCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "USER_COLLECTION_CELL")
    collectionView.dataSource = self
    collectionView.delegate = self
    
    
    networkController = NetworkController.sharedInstance
    
    
  }
  
  //MARK: - TableViewDataSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if backingArray != nil {
      return backingArray!.count
    } else {
      return 0
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.searchBar.setNeedsLayout()
    self.collectionView.collectionViewLayout.invalidateLayout()
    self.collectionView.reloadData()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    self.changeTitleTo("Search")
  }
  
  
  
   override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = self.tableView.frame
  }
  
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
      networkController.fetchImageFromURL(repo.avatarURL, completionHandler: { (image) -> Void in
        cell.avatarImage.image = image
      })
      return cell
    }
    
    if let user = object as? User {
      let cell = tableView.dequeueReusableCellWithIdentifier("USER_CELL", forIndexPath: indexPath) as UserCell
      cell.avatarImage.image = nil
      cell.username.text = user.login
      networkController.fetchImageFromURL(user.avatarURL, completionHandler: { (image) -> Void in
        cell.avatarImage.image = image
      })
      return cell
    }
    return UITableViewCell()
  }
  
  
  func setUpTableView() {
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 150.0
    tableView.registerNib(UINib(nibName: "RepoCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "REPO_CELL")
    tableView.registerNib(UINib(nibName: "UserCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "USER_CELL")
  }
  
  func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    currentScope = Scope(rawValue: selectedScope)!
    if countElements(searchBar.text) > 0{
      doSearch()
    }
    
    if currentScope == .Users {
      self.view.addSubview(collectionView)
    } else{
      self.collectionView.removeFromSuperview()
    }
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    doSearch()
    searchBar.resignFirstResponder()
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if backingArray != nil {
      return backingArray!.count
    } else {
      return 0
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("USER_COLLECTION_CELL", forIndexPath: indexPath) as UserCollectionCell
    cell.spinningWheel.startAnimating()
    cell.avatarImage.image = nil
    cell.nameLabel.text = nil
    cell.nameLabel.alpha = 1.0
    if let thisUser = backingArray![indexPath.row] as? User{
        networkController.fetchImageFromURL(thisUser.avatarURL, completionHandler: { (image) -> Void in
          cell.avatarImage.image = image
          cell.nameLabel.text = thisUser.login
          cell.spinningWheel.stopAnimating()
        })
      }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PROFILE_VC") as ProfileViewController
    selectedCell = collectionView.cellForItemAtIndexPath(indexPath)
    let selectedUser = backingArray![indexPath.row] as? User
    vc.wantedUserName = selectedUser!.login
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  
  
  func doSearch(){
    self.tableView.alpha = 0.0
    networkController.fetchReposFromSearchTerm(searchBar.text, type: currentScope, completionHandler: { (errorDescription, result) -> (Void) in
      if errorDescription == nil {
        self.backingArray = result
        self.tableView.reloadData()
        self.collectionView.reloadData()
        self.changeTitleTo("Showing results for \"\(self.searchBar.text)\"")
        UIView.transitionWithView(self.tableView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
          self.tableView.alpha = 1.0
          }, completion: nil)
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
  
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if let sourceVC = fromVC as? SearchViewController{
      if currentScope == .Users {
        let animator = EnlargeAnimation()
        return animator
      }
    }
    return nil
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