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
  @IBOutlet weak var sourceImageView: DownloadableImageView!
  @IBOutlet weak var sourceNameLabel: UILabel!
  @IBOutlet weak var likesCountLabel: UILabel!
  @IBOutlet weak var commentsCountLabel: UILabel!
  @IBOutlet weak var repostsCountLabel: UILabel!
  @IBOutlet weak var viewsCountLabel: UILabel!
  @IBOutlet weak var singleImageView: DownloadableImageView!
  @IBOutlet weak var galleryScrollView: UIScrollView!
  @IBOutlet weak var postDateLabel: UILabel!
  
  var aspectConstraint: NSLayoutConstraint?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if let card = UIImage(named: "CardWithShadow") {
      backgroundImageView.image = card.resizableImage(withCapInsets: UIEdgeInsets(
        top: 14,
        left: 32,
        bottom: 31,
        right: 31))
    }
  }
  
  func setupCell(post: Post, state: NewsfeedCellState) {
    sourceNameLabel.text = post.source.name
    postDateLabel.text = post.date.toRelativeDateString()
    postTextLabel.text = post.text
    
    likesCountLabel.text = post.likes.toShortString()
    commentsCountLabel.text = post.comments.toShortString()
    repostsCountLabel.text = post.reposts.toShortString()
    viewsCountLabel.text = post.views.toShortString()
    
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
