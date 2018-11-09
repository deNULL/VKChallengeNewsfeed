//
//  PostTableViewCell.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit

struct NewsfeedCellState {
  var isExpanded: Bool
  var selectedPhoto: Int
}

class NewsfeedCell: UITableViewCell {
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
  
  var aspectConstraint: NSLayoutConstraint?
  
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
  
  func getShortNumber(n: Int) -> String {
    if n > 10000000 || (n > 1000000 && (n / 100000) % 10 == 0) {
      return String(n / 1000000) + "M";
    } else
      if n > 1000000 {
        return String(Float(n / 100000) / 10) + "M";
      } else
        if n > 10000 || (n > 1000 && (n / 100) % 10 == 0) {
          return String(n / 1000) + "K";
        } else
          if n > 1000 {
            return String(Float(n / 100) / 10) + "K";
          } else {
            return String(n);
    }
  }
  
  func getDateTime(dt: Int) {
    
  }
  
  func setupCell(post: Post, state: NewsfeedCellState) {
    sourceNameLabel.text = post.source.name
    postDateLabel.text = ""
    postTextLabel.text = post.text
    
    likesCountLabel.text = getShortNumber(n: post.likes)
    commentsCountLabel.text = getShortNumber(n: post.comments)
    repostsCountLabel.text = getShortNumber(n: post.reposts)
    viewsCountLabel.text = getShortNumber(n: post.views)
    
    sourceImageView.downloadImageFrom(link: post.source.photo, contentMode: UIView.ContentMode.scaleAspectFit)
    
    singleImageView.image = nil
    if aspectConstraint != nil {
      singleImageView.removeConstraint(aspectConstraint!)
    }
    
    if post.attachments.count == 1 {
      let photo = (post.attachments[0] as! Photo)
      
      aspectConstraint = NSLayoutConstraint(
        item: singleImageView,
        attribute: NSLayoutConstraint.Attribute.width,
        relatedBy: NSLayoutConstraint.Relation.equal,
        toItem: singleImageView,
        attribute: NSLayoutConstraint.Attribute.height,
        multiplier: CGFloat(photo.maximumSize.width) / CGFloat(photo.maximumSize.height),
        constant: 0.0)
      singleImageView.addConstraint(aspectConstraint!)
      singleImageView.downloadImageFrom(link: photo.minimumSize.url,
                                             contentMode: UIView.ContentMode.scaleToFill)
    } else
    if post.attachments.count > 1 {
      singleImageView.image = nil
    } else {
      singleImageView.image = nil
    }
  }

}
