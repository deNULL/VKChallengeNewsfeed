//
//  PostTableViewCell.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
  @IBOutlet weak var postTextLabel: UILabel!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var sourceImageView: UIImageView!
  @IBOutlet weak var sourceNameLabel: UILabel!
  @IBOutlet weak var likesCountLabel: UILabel!
  @IBOutlet weak var commentsCountLabel: UILabel!
  @IBOutlet weak var repostsCountLabel: UILabel!
  @IBOutlet weak var viewsCountLabel: UILabel!
  @IBOutlet weak var singleImageView: UIImageView!
  @IBOutlet weak var galleryScrollView: UIScrollView!
  @IBOutlet weak var postDateLabel: UILabel!
  @IBOutlet weak var aspectConstraint: NSLayoutConstraint!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      if let card = UIImage(named: "CardWithShadow") {
        backgroundImageView.image = card.resizableImage(withCapInsets: UIEdgeInsets(top: 14, left: 32, bottom: 31, right: 31))
      }
      
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
