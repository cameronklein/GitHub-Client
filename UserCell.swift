//
//  UserCell.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/21/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

  @IBOutlet weak var username: UILabel!
  
  @IBOutlet weak var avatarImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  
}
