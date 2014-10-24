//
//  StringExtension.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/23/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import Foundation

extension String {
  
  func validate() -> Bool {
    
    let expression = NSRegularExpression(pattern: "[^0-9a-zA-Z\n]", options: nil, error: nil)
    let numOfMatches = expression?.numberOfMatchesInString(self, options: nil, range: NSRange(location: 0, length: countElements(self)))
    if numOfMatches > 0 {
      println("Found matches")
      return false
    }
    return true
  }
  
}