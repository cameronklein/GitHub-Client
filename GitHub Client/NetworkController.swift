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
  var token :String!
  
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
          println(token)
//          self.headers = NSMutableDictionary()
//          self.headers["Authorization"] = NSString(UTF8String: "token " + token!)
          self.token = token
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
  
  func fetchReposFromSearchTerm(searchTerm: String, completionHandler : (errorDescription: String?, repos: [Repo]?) -> (Void)) {
    //let config = NSURLSessionConfiguration()
    //config.HTTPAdditionalHeaders = headers
    let session = NSURLSession.sharedSession()
    
    let url = NSURL(string: "https://api.github.com/search/repositories?q=" + searchTerm + "&access_token" + token)
    let request = NSURLRequest(URL: url!)
    let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      var repos : [Repo]?
      var errorDescription : String?
      if error != nil {
        errorDescription = "Server request not sent. Something is wrong."
      } else {
        let response = response as NSHTTPURLResponse
        switch response.statusCode {
        case 200...299:
          repos = Repo.parseJSONIntoRepos(data)
        case 400...499:
          errorDescription = "Something went wrong on our end."
        case 500...599:
          errorDescription = "Something is wrong with GitHub's servers."
        default:
          errorDescription = "Something is very, very wrong."
        }
      }
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        completionHandler(errorDescription: errorDescription, repos: repos)
      })
    })

    dataTask.resume()
    
  }

}