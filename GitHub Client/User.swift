//
//  Repo.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/20/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import Foundation


class User : Scorable{
  
  var id          : Int!
  var login       : String!
  var avatarURL   : String!
  var score       : Double!
  var name        : String?
  var location    : String?
  var bio         : String?
  var publicRepos : Int?
  var publicGists : Int?
  
  
  init(dictionary: NSDictionary){
    id          = dictionary["id"]                as Int
    login        = dictionary["login"]            as String
    avatarURL   = dictionary["avatar_url"]        as String
    score       = dictionary["score"]             as? Double
    

  }
  
  class func parseJSONIntoUsers (data: NSData) -> [User]? {
    var error : NSError?
    if let searchResultsDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? NSDictionary {
      var users = [User]()
      if let userArray = searchResultsDictionary["items"] as? NSArray {
        for dictionary in userArray {
          if let userDict = dictionary as? NSDictionary {
            users.append(User(dictionary: userDict))
          }
        }
      }
      println("\(users.count) users created.")
      return users
    }
    return nil
    
    
    
    
  }
  
}