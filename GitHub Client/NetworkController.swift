//
//  NetworkController.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/20/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import Foundation

class NetworkController{
    
    class var sharedInstance : NetworkController {
    struct Static {
      static let instance : NetworkController = NetworkController()
      }
      return Static.instance
    }
  
  func fetchReposFromSearchTerm(searchTerm: String, completionHandler : (errorDescription: String?, repos: [Repo]?) -> (Void)) {
  
    let session = NSURLSession.sharedSession()
    let url = NSURL(string: "http://127.0.0.1:3000")
    
    let request = NSURLRequest(URL: url)
    
    let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      
      if error != nil {
        println("Error!")
      } else {
        let response = response as NSHTTPURLResponse
        let statusCode = response.statusCode
        switch statusCode {
        case 200...299:
          let repos = Repo.parseJSONIntoRepos(data)
          
          println("Should return!")
          completionHandler(errorDescription: nil, repos: repos)
        default:
          println("Oops!")
        }
      }
      
    })

    dataTask.resume()
    
  }

}