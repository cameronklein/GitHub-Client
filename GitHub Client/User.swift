//
//  Repo.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/20/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import Foundation


class User {
  
  var id : Int!
  var name : String!
  var avatarURL : String!
  
  init(dictionary: NSDictionary){
    id          = dictionary["id"]                as Int
    name        = dictionary["login"]             as String
    avatarURL   = dictionary["avatar_url"]        as String

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