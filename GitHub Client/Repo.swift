//
//  Repo.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/20/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import Foundation


class Repo : Scorable {
  
  var id : Int!
  var name : String!
  var url : String!
  var description: String?
  var owner : String!
  var stars: Int!
  var watchers : Int!
  var forks: Int!
  var avatarURL : String!
  var score : Double!
  
  init(dictionary: NSDictionary){
    id          = dictionary["id"]                as Int
    name        = dictionary["name"]              as String
    url         = dictionary["html_url"]          as String
    description = dictionary["description"]       as? String
    stars       = dictionary["stargazers_count"]  as Int
    watchers    = dictionary["watchers_count"]    as Int
    forks       = dictionary["forks_count"]       as Int
    score       = dictionary["score"]             as? Double
    
    let ownerDictionary = dictionary["owner"] as NSDictionary
    owner = ownerDictionary["login"] as String
    avatarURL = ownerDictionary["avatar_url"] as String
  
  }
  
  class func parseJSONIntoRepos (data: NSData) -> [Repo]? {
    var error : NSError?
    if let searchResultsDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? NSDictionary {
      var repos = [Repo]()
      if let repoArray = searchResultsDictionary["items"] as? NSArray {
                for dictionary in repoArray {
          if let repoDict = dictionary as? NSDictionary {
            repos.append(Repo(dictionary: repoDict))
          }
        }
      } else {
      repos.append(Repo(dictionary: searchResultsDictionary))
      }
      println("\(repos.count) repos created.")
      return repos
    } else if let searchResultsArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? NSArray {
        var repos = [Repo]()
          for dictionary in searchResultsArray {
            if let repoDict = dictionary as? NSDictionary {
              repos.append(Repo(dictionary: repoDict))
            }
          }
        println("\(repos.count) repos created.")
        return repos
      }
    return nil

  }
  
}