//
//  RepoCell.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/20/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class RepoCell: UITableViewCell {
  @IBOutlet weak var avatarImage: UIImageView!
  @IBOutlet weak var ownerName: UILabel!
  @IBOutlet weak var watchers: UILabel!
  @IBOutlet weak var forks: UILabel!
  @IBOutlet weak var repoName: UILabel!
  @IBOutlet weak var stars: UILabel!
  @IBOutlet weak var forkIcon: UILabel!
  @IBOutlet weak var starsIcon: UILabel!
  @IBOutlet weak var watchersIcon: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

      
    }

}
