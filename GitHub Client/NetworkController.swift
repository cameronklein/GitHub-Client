//
//  NetworkController.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/20/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class NetworkController{
    
    class var sharedInstance : NetworkController {
    struct Static {
      static let instance : NetworkController = NetworkController()
      }
      return Static.instance
    }
  
  let clientID        = "client_id=f77fba362cf46d2474f7"
  let clientSecret    = "client_secret=c8b0998cae152bbf1a8f307c1ac5fb1532e58b43"
  let githubOAuthURL  = "http://github.com/login/oauth/authorize?"
  let scope           = "scope=user,repo"
  let redirectURL     = "redirect_uri=camsgithubclient://test"
  let githubTokenURL  = "https://github.com/login/oauth/access_token"
  
  var usersRunFlag    = false
  var imageCache      = [String:UIImage]()
  var imageQueue      = NSOperationQueue()
  
  func requestOAuthAccess() {
    let url = githubOAuthURL + clientID + "&" + redirectURL + "&" + scope
    UIApplication.sharedApplication().openURL(NSURL(string: url)!)
  }
  
  func handleOAuthURL(callbackURL: NSURL) {
    let query = callbackURL.query
    let components = query?.componentsSeparatedByString("code=")
    let code = components?.last
    
    let urlQuery = clientID + "&" + clientSecret + "&" + query!
    
    println(urlQuery)
    
    var request = NSMutableURLRequest(URL: NSURL(string: githubTokenURL)!)
    request.HTTPMethod = "POST"
    var postData = urlQuery.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
    var length = postData?.length
    request.setValue("\(length)", forHTTPHeaderField: "Content-Length")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = postData
    
    let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      if error != nil {
        println(error.description)
      } else {
        let response = response as NSHTTPURLResponse
        switch response.statusCode {
        case 200...299:
          var tokenResponse = NSString(data: data!, encoding: NSASCIIStringEncoding)!
          let response = tokenResponse as String
          println(response)
          let token = response.componentsSeparatedByString("&").first?.componentsSeparatedByString("=").last
          println(token!)
          NSUserDefaults.standardUserDefaults().setObject(NSString(string: token!), forKey: "OAuth")
          NSUserDefaults.standardUserDefaults().synchronize()
        case 400...499:
          println("Something went wrong on our end.")
        case 500...599:
          println("Something is wrong with GitHub's servers.")
        default:
          println("Something is very, very wrong.")
        }
      }
      
    })
    
    dataTask.resume()
  }
  
  func fetchReposFromSearchTerm(searchTerm: String, type: Scope, tempArray: [Repo]? = nil, completionHandler : (errorDescription: String?, result: [AnyObject]?) -> (Void)) {
    let session = NSURLSession.sharedSession()
    
    var checkedType = type
    if checkedType == .All{
      if tempArray == nil{
        checkedType = .Repos
      } else {
        checkedType = .Users
      }
    }
    
    let newSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
    let url = NSURL(string: "https://api.github.com/search/" + checkedType.toString() + "?q=" + newSearchTerm)
    println(url?.description)
    let request = NSMutableURLRequest(URL: url!)
    let token = NSUserDefaults.standardUserDefaults().objectForKey("OAuth") as String
    println(token)
    request.setValue("token " + token, forHTTPHeaderField: "Authorization")
    let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      var errorDescription : String?
      if error != nil {
        errorDescription = "Server request not sent. Something is wrong."
      } else {
        let response = response as NSHTTPURLResponse
        switch response.statusCode {
        case 200...299:
          switch type{
          case .Repos:
            let result = Repo.parseJSONIntoRepos(data) as [AnyObject]?
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              completionHandler(errorDescription: errorDescription, result: result)
            })
          case .Users:
            let result = User.parseJSONIntoUsers(data) as [AnyObject]?
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              completionHandler(errorDescription: errorDescription, result: result)
            })
          case .All:
            if tempArray == nil {
              let result = Repo.parseJSONIntoRepos(data)
              self.fetchReposFromSearchTerm(searchTerm, type: .All, tempArray: result, completionHandler: completionHandler)
            } else {
              var result = User.parseJSONIntoUsers(data)
              var totalArray = [Scorable]()
              for item in result! {
                totalArray.append(item)
                println("User Added!")
              }
              for item in tempArray! {
                totalArray.append(item)
                println("Repo Added!")
              }
              totalArray.sort({ $0.score > $1.score })
              var thirdArray = [AnyObject]()
              for item in totalArray{
                thirdArray.append(item)
              }
              NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(errorDescription: errorDescription, result: thirdArray)
              })
            }
          }
        case 400...499:
          errorDescription = "Something went wrong on our end."
        case 500...599:
          errorDescription = "Something is wrong with GitHub's servers."
        default:
          errorDescription = "Something is very, very wrong."
        }
      }
      if let error = errorDescription{
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          completionHandler(errorDescription: error, result: nil)
        })
      }
    })
    dataTask.resume()
  }
  
  func fetchUserRepos(username : String? = nil, completionHandler : (errorDescription: String?, result: [Repo]?) -> (Void)) {
    let session = NSURLSession.sharedSession()
    var urlString = "https://api.github.com/user/repos"
    if let login = username{
      urlString = "https://api.github.com/users/\(login)/repos"
    }
    let url = NSURL(string: urlString)
    let request = NSMutableURLRequest(URL: url!)
    let token = NSUserDefaults.standardUserDefaults().objectForKey("OAuth") as String
    request.setValue("token " + token, forHTTPHeaderField: "Authorization")
    let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      var errorDescription : String?
      var result : [Repo]?
      if error != nil {
        errorDescription = "Server request not sent. Something is wrong."
      } else {
        let response = response as NSHTTPURLResponse
        switch response.statusCode {
        case 200...299:
          println("Got 200!")
          result = Repo.parseJSONIntoRepos(data) as [Repo]?
        case 400...499:
          errorDescription = "Something went wrong on our end."
        case 500...599:
          errorDescription = "Something is wrong with GitHub's servers."
        default:
          errorDescription = "Something is very, very wrong."
        }
      }
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        completionHandler(errorDescription: errorDescription, result: result)
      })
    
    })
    dataTask.resume()
  }
  
  func fetchUserGists(username : String? = nil, completionHandler : (errorDescription: String?, result: [Repo]?) -> (Void)) {
    let session = NSURLSession.sharedSession()
    var urlString = "https://api.github.com/user/gists"
    if let login = username{
      urlString = "https://api.github.com/users/\(login)/gists"
    }
    let url = NSURL(string: urlString)
    let request = NSMutableURLRequest(URL: url!)
    let token = NSUserDefaults.standardUserDefaults().objectForKey("OAuth") as String
    request.setValue("token " + token, forHTTPHeaderField: "Authorization")
    let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      var errorDescription : String?
      var result : [Repo]?
      if error != nil {
        errorDescription = "Server request not sent. Something is wrong."
      } else {
        let response = response as NSHTTPURLResponse
        switch response.statusCode {
        case 200...299:
          println("Got 200!")
          result = Repo.parseJSONIntoRepos(data) as [Repo]?
        case 400...499:
          errorDescription = "Something went wrong on our end."
        case 500...599:
          errorDescription = "Something is wrong with GitHub's servers."
        default:
          errorDescription = "Something is very, very wrong."
        }
      }
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        completionHandler(errorDescription: errorDescription, result: result)
      })
      
    })
    dataTask.resume()
  }
  
  func getUser(username: String? = nil, completionHandler : (errorDescription: String?, result: User?) -> (Void)) {
    let session = NSURLSession.sharedSession()
    
    var urlString = "https://api.github.com/user"
    
    if let login = username {
      urlString = "https://api.github.com/users/" + login
    }
    println(urlString)
    
    var url = NSURL(string: urlString)
    
    let request = NSMutableURLRequest(URL: url!)
    let token = NSUserDefaults.standardUserDefaults().objectForKey("OAuth") as String
    request.setValue("token " + token, forHTTPHeaderField: "Authorization")
    
    let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      var errorDescription : String?
      var currentUser : User?
      if error != nil {
        errorDescription = "Server request not sent. Something is wrong."
      } else {
        let response = response as NSHTTPURLResponse
        switch response.statusCode {
        case 200...299:
          var error : NSError?
          let result = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as NSDictionary
          currentUser = User(dictionary: result)
        case 400...499:
          errorDescription = "Something went wrong on our end."
        case 500...599:
          errorDescription = "Something is wrong with GitHub's servers."
        default:
          errorDescription = "Something is very, very wrong."
        }
      }
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        completionHandler(errorDescription: errorDescription, result: currentUser)
      })
    })
    dataTask.resume()
  }
  
  func fetchImageFromURL(url : String, completionHandler: (UIImage?) -> Void) {
    imageQueue.addOperationWithBlock({ () -> Void in
      var image : UIImage?
      if let cachedImage = self.imageCache[url]{
        image = cachedImage
      } else {
        let uri   = NSURL(string: url)
        let data  = NSData(contentsOfURL: uri!)
        image = UIImage(data: data!)
        self.imageCache[url] = image!
        }
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        completionHandler(image!)
      })
    })
    
  }
  
  

}