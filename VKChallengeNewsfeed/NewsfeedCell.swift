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

protocol NewsfeedCellDelegate {
  func selectedPhotoChanged(cell: NewsfeedCell, selectedPhoto: Int)
  func expandedText(cell: NewsfeedCell)
  func tappedLink(link: String)
}

class NewsfeedCell: UITableViewCell, UIScrollViewDelegate {
  @IBOutlet weak var postTextLabel: PostTextLabel!
  @IBOutlet weak var postTextConstraint: NSLayoutConstraint!
  @IBOutlet weak var expandTextLabel: UILabel!
  @IBOutlet weak var expandTextConstraint: NSLayoutConstraint!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var sourceImageView: DownloadableImageView!
  @IBOutlet weak var sourceNameLabel: UILabel!
  @IBOutlet weak var likesCountLabel: UILabel!
  @IBOutlet weak var commentsCountLabel: UILabel!
  @IBOutlet weak var repostsCountLabel: UILabel!
  @IBOutlet weak var viewsCountLabel: UILabel!
  @IBOutlet weak var singleImageView: DownloadableImageView!
  @IBOutlet weak var galleryContainerView: UIView!
  @IBOutlet weak var galleryScrollView: UIScrollView!
  @IBOutlet weak var galleryContentView: UIView!
  @IBOutlet weak var galleryPageControl: UIPageControl!
  @IBOutlet weak var gallerySeparatorView: UIView!
  @IBOutlet weak var postDateLabel: UILabel!
  
  var singleAspectConstraint: NSLayoutConstraint?
  var galleryAspectConstraint: NSLayoutConstraint?
  
  var galleryImageViews: [DownloadableImageView] = []
  var galleryConstraints: [NSLayoutConstraint] = []
  
  var delegate: NewsfeedCellDelegate? = nil
  var index: Int = 0
  var post: Post? = nil
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if let card = UIImage(named: "CardWithShadow") {
      backgroundImageView.image = card.resizableImage(withCapInsets: UIEdgeInsets(
        top: 14,
        left: 32,
        bottom: 31,
        right: 31))
    }
    
    if galleryScrollView != nil {
      galleryScrollView.delegate = self
    }
  
    expandTextLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapExpand)))
    
    postTextLabel.onCharacterTapped = characterTapped
  }
  
  func characterTapped(label: UILabel, index: Int) {
    let attrs = postTextLabel.attributedText?.attributes(at: index, effectiveRange: nil)
    if let link = attrs?[NSAttributedString.Key.link] as? String {
      delegate?.tappedLink(link: link)
    }
  }
  
  override func layoutSubviews() {
    //
  }
  
  static var measuringLabel: PostTextLabel = PostTextLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
  static func calculateHeight(post: Post, state: NewsfeedCellState, width: CGFloat) -> CGFloat {
    var height: CGFloat = 58.0 /* Above text */ + 44.0 /* Buttons below */ + 12.0 /* Spacing */
    measuringLabel.numberOfLines = 0
    measuringLabel.frame = CGRect(x: 0, y: 0, width: width - 24, height: 0)
    measuringLabel.parseText(text: post.text, query: nil, dirty: true)
    let lines = measuringLabel.calculateMaxLines()
    let isExpanded = state.isExpanded || lines <= 8
    if isExpanded {
      height += CGFloat(lines) * 22.0
    } else {
      height += 7 * 22.0
    }
    
    let isGallery = post.attachments.count > 1
    if isGallery {
      let photo = (post.attachments[0] as! Photo)
      height += CGFloat(photo.maximumSize.height) * (width / CGFloat(photo.maximumSize.width))
      height += 6.0 + 39.0
    } else
    if post.attachments.count > 0 {
      let photo = (post.attachments[0] as! Photo)
      height += CGFloat(photo.maximumSize.height) * (width / CGFloat(photo.maximumSize.width))
      height += 6.0 + 4.0
    } else {
      height += 4.0
    }
    
    return height
  }
  
  func setupCell(index: Int, post: Post, state: NewsfeedCellState, query: String?) {
    self.index = index
    self.post = post
    
    sourceNameLabel.text = post.source.name
    postDateLabel.text = post.date.toRelativeDateString()
    postTextLabel.parseText(text: post.text, query: query, dirty: false)
    
    let isExpanded = state.isExpanded || postTextLabel.calculateMaxLines() <= 8
    expandTextLabel.isHidden = isExpanded
    expandTextConstraint.constant = isExpanded ? 0.0 : 22.0
    postTextLabel.numberOfLines = isExpanded ? 0 : 6
    
    likesCountLabel.text = post.likes.toShortString()
    commentsCountLabel.text = post.comments.toShortString()
    repostsCountLabel.text = post.reposts.toShortString()
    viewsCountLabel.text = post.views.toShortString()
    
    sourceImageView.downloadImageFrom(link: post.source.photo, contentMode: UIView.ContentMode.scaleAspectFit)
    
    postTextConstraint.constant = post.attachments.count > 0 ? 6.0 : 0.0
    
    let isGallery = post.attachments.count > 1
    if isGallery {
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
        galleryContentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        
        let constraintWidth = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: galleryScrollView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: -4.0)
        galleryScrollView.addConstraint(constraintWidth)
        
        let constraintHeight = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: galleryScrollView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.0, constant: 0.0)
        galleryScrollView.addConstraint(constraintHeight)
        
        let constraintTop = previousImageView == nil ? NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: galleryContentView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0) :
          NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: previousImageView!, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0.0)
        galleryScrollView.addConstraint(constraintTop)
        
        let constraintLeft = previousImageView == nil ?
          NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: galleryContentView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 2.0) :
          NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: previousImageView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 4.0)
        galleryScrollView.addConstraint(constraintLeft)
        
        
        imageView.downloadImageFrom(link: photo.minimumSize.url, contentMode: UIView.ContentMode.scaleAspectFill)
        
        previousImageView = imageView
        galleryImageViews.append(imageView)
        galleryConstraints.append(contentsOf: [constraintWidth, constraintHeight, constraintLeft, constraintTop])
      }
      
      let constraintRight = NSLayoutConstraint(item: previousImageView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: galleryContentView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 2.0)
      galleryScrollView.addConstraint(constraintRight)
      galleryConstraints.append(constraintRight)
      
      let x = CGFloat(state.selectedPhoto) * galleryScrollView.frame.size.width
      galleryScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
    } else {
      singleImageView.cancelDownload()
      singleImageView.image = nil
      if singleAspectConstraint != nil {
        singleImageView.removeConstraint(singleAspectConstraint!)
      }
      
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
        //singleAspectConstraint?.priority = UILayoutPriority.defaultHigh
        singleImageView.addConstraint(singleAspectConstraint!)
        singleImageView.downloadImageFrom(link: photo.minimumSize.url,
                                          contentMode: UIView.ContentMode.scaleToFill)
      }
    }
  }
  
  @IBAction func pageChanged(_ sender: UIPageControl) {
    let x = CGFloat(sender.currentPage) * galleryScrollView.frame.size.width
    galleryScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    delegate?.selectedPhotoChanged(cell: self, selectedPhoto: sender.currentPage)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let value = scrollView.contentOffset.x / scrollView.frame.size.width
    galleryPageControl.currentPage = Int(round(value))
    delegate?.selectedPhotoChanged(cell: self, selectedPhoto: Int(round(value)))
  }
  
  @objc func tapExpand() {
    delegate?.expandedText(cell: self)
  }
}
