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
  @IBOutlet weak var galleryPageControl: UIPageControl!
  @IBOutlet weak var gallerySeparatorView: UIView!
  @IBOutlet weak var postDateLabel: UILabel!
  
  var singleAspectConstraint: NSLayoutConstraint?
  var galleryAspectConstraint: NSLayoutConstraint?
  
  var galleryImageViews: [DownloadableImageView] = []
  var galleryConstraints: [NSLayoutConstraint] = []
  
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
    
    singleImageView.isHidden = post.attachments.count > 1
    singleImageView.cancelDownload()
    singleImageView.image = nil
    if singleAspectConstraint != nil {
      singleImageView.removeConstraint(singleAspectConstraint!)
    }
    
    galleryScrollView.isHidden = post.attachments.count <= 1
    galleryPageControl.isHidden = post.attachments.count <= 1
    gallerySeparatorView.isHidden = post.attachments.count <= 1
    if galleryAspectConstraint != nil {
      galleryScrollView.removeConstraint(galleryAspectConstraint!)
    }
    galleryScrollView.removeConstraints(galleryConstraints)
    for imageView in galleryImageViews {
      imageView.cancelDownload()
      imageView.removeFromSuperview()
    }
    galleryImageViews = []
    galleryConstraints = []
    
    if post.attachments.count == 1 {
      let photo = (post.attachments[0] as! Photo)
      
      singleAspectConstraint = NSLayoutConstraint(
        item: singleImageView,
        attribute: NSLayoutConstraint.Attribute.width,
        relatedBy: NSLayoutConstraint.Relation.equal,
        toItem: singleImageView,
        attribute: NSLayoutConstraint.Attribute.height,
        multiplier: CGFloat(photo.maximumSize.width) / CGFloat(photo.maximumSize.height),
        constant: 0.0)
      singleImageView.addConstraint(singleAspectConstraint!)
      singleImageView.downloadImageFrom(link: photo.minimumSize.url,
                                        contentMode: UIView.ContentMode.scaleToFill)
    } else
    if post.attachments.count > 1 {
      let photo = (post.attachments[0] as! Photo) // TODO: how to calculate aspect if it's different for each photo?
      
      galleryPageControl.numberOfPages = post.attachments.count
      galleryPageControl.currentPage = state.selectedPhoto
      galleryAspectConstraint = NSLayoutConstraint(
        item: galleryScrollView,
        attribute: NSLayoutConstraint.Attribute.width,
        relatedBy: NSLayoutConstraint.Relation.equal,
        toItem: galleryScrollView,
        attribute: NSLayoutConstraint.Attribute.height,
        multiplier: CGFloat(photo.maximumSize.width) / CGFloat(photo.maximumSize.height),
        constant: 0.0)
      galleryScrollView.addConstraint(galleryAspectConstraint!)
        
      var previousImageView: UIImageView? = nil
      for photo in post.attachments as! [Photo] {
        let imageView = DownloadableImageView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        galleryScrollView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraintWidth = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: galleryScrollView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: 0.0)
        galleryScrollView.addConstraint(constraintWidth)
        
        let constraintHeight = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: galleryScrollView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.0, constant: 0.0)
        galleryScrollView.addConstraint(constraintHeight)
        
        let constraintTop = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: galleryScrollView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0)
       galleryScrollView.addConstraint(constraintTop)
        
        let constraintLeft = previousImageView == nil ?
          NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: galleryScrollView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0) :
          NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: previousImageView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0)
        galleryScrollView.addConstraint(constraintLeft)
        
        
        imageView.downloadImageFrom(link: photo.minimumSize.url, contentMode: UIView.ContentMode.scaleAspectFill)
        
        previousImageView = imageView
        galleryImageViews.append(imageView)
        galleryConstraints.append(contentsOf: [constraintWidth, constraintHeight, constraintLeft, constraintTop])
      }
      
      let constraintRight = NSLayoutConstraint(item: previousImageView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: galleryScrollView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0)
      galleryScrollView.addConstraint(constraintRight)
      galleryConstraints.append(constraintRight)
    }
  }

}
