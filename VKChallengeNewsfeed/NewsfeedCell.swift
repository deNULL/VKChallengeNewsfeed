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
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var sourceImageView: DownloadableImageView!
  @IBOutlet weak var sourceNameLabel: UILabel!
  @IBOutlet weak var postDateLabel: UILabel!
  @IBOutlet var postTextLabel: PostTextLabel!
  @IBOutlet weak var expandTextLabel: UILabel!
  @IBOutlet weak var singleImageView: DownloadableImageView!
  @IBOutlet weak var galleryContainerView: UIView!
  @IBOutlet weak var galleryScrollView: UIScrollView!
  @IBOutlet weak var galleryContentView: UIView!
  @IBOutlet weak var galleryPageControl: UIPageControl!
  @IBOutlet weak var gallerySeparatorView: UIView!
  @IBOutlet weak var likesImageView: UIImageView!
  @IBOutlet weak var likesCountLabel: UILabel!
  @IBOutlet weak var commentsImageView: UIImageView!
  @IBOutlet weak var commentsCountLabel: UILabel!
  @IBOutlet weak var repostsImageView: UIImageView!
  @IBOutlet weak var repostsCountLabel: UILabel!
  @IBOutlet weak var viewsImageView: UIImageView!
  @IBOutlet weak var viewsCountLabel: UILabel!
  
  var galleryImageViews: [DownloadableImageView] = []
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
  
  static let measuringInstance: NewsfeedCell = {
    let cell = NewsfeedCell(frame: .zero)
    cell.postTextLabel = PostTextLabel(frame: .zero)
    return cell
  }()
  
  static func calculateHeight(index: Int, post: Post, state: NewsfeedCellState, width: CGFloat) -> CGFloat {
    return measuringInstance.setupCell(index: index, post: post, state: state, query: nil, width: width, measureOnly: true)
  }
  
  let LINE: CGFloat = 22.0
  func setupCell(index: Int, post: Post, state: NewsfeedCellState, query: String?, width: CGFloat, measureOnly: Bool) -> CGFloat {
    self.index = index
    self.post = post
    
    var y: CGFloat = 0
  
    if !measureOnly {
      sourceImageView.image = nil
      sourceImageView.downloadImageFrom(link: post.source.photo, contentMode: UIView.ContentMode.scaleAspectFit)
      
      sourceNameLabel.text = post.source.name
      sourceNameLabel.frame = CGRect(x: 70, y: 14, width: width - 90, height: 17)
      
      postDateLabel.text = post.date.toRelativeDateString()
      postDateLabel.frame = CGRect(x: 70, y: 32, width: width - 90, height: 14.33)
    }
    
    y += 58
    
    postTextLabel.parseText(text: post.text, query: query, dirty: false)
    let postTextFullHeight = postTextLabel.calculateHeight(width: width - 40)
    let postTextLines = Int(ceil(postTextFullHeight / LINE))
    let isExpanded = state.isExpanded || postTextLines <= 8
    let postTextHeight = isExpanded ? postTextFullHeight : (LINE * 6)
    
    if !measureOnly {
      postTextLabel.numberOfLines = isExpanded ? 0 : 6
      postTextLabel.frame = CGRect(x: 20, y: y, width: width - 40, height: postTextHeight)
    }
    
    y += postTextHeight + 6
    
    if !measureOnly {
      expandTextLabel.isHidden = isExpanded
      if !isExpanded {
        expandTextLabel.frame = CGRect(x: 20, y: y - 22, width: expandTextLabel.frame.width, height: 18)
      }
    }
    
    if !isExpanded {
      y += 16
    }
    
    
    if post.attachments.count > 0 {
      let photo = (post.attachments[0] as! Photo)
      let aspect = CGFloat(photo.maximumSize.width) / CGFloat(photo.maximumSize.height)
      
      if post.attachments.count > 1 {
        for imageView in galleryImageViews {
          imageView.cancelDownload()
          imageView.removeFromSuperview()
        }
        galleryImageViews = []
        
        // TODO: how to calculate aspect if it's different for each photo?
        let height = (width - 40) / aspect
        if !measureOnly {
          galleryContainerView.frame = CGRect(x: 8, y: y, width: width - 16, height: height)
          galleryScrollView.frame = CGRect(x: 10, y: 0, width: width - 36, height: height)

          var x: CGFloat = 2
          for photo in post.attachments as! [Photo] {
            let imageView = DownloadableImageView(frame: CGRect(x: x, y: 0, width: width - 40, height: height))
            galleryContentView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.clipsToBounds = true
            
            x += 4 + width - 40
            imageView.downloadImageFrom(link: photo.minimumSize.url, contentMode: UIView.ContentMode.scaleAspectFill)
            
            galleryImageViews.append(imageView)
          }
          galleryContentView.frame = CGRect(x: 0, y: 0, width: x - 2, height: height)
          galleryScrollView.contentSize = CGSize(width: x - 2, height: height)
        }
        
        y += height
        
        if !measureOnly {
          galleryPageControl.frame = CGRect(x: 8, y: y, width: width - 16, height: 37)
          galleryPageControl.numberOfPages = post.attachments.count
          galleryPageControl.currentPage = state.selectedPhoto
        }
        
        y += 37
        
        if !measureOnly {
          gallerySeparatorView.frame = CGRect(x: 20, y: y, width: width - 40, height: 1)
        }
        
        y += 10
      } else {
        if !measureOnly {
          singleImageView.cancelDownload()
          singleImageView.image = nil
        }
        
        let height = (width - 16) / aspect
        if !measureOnly {
          singleImageView.frame = CGRect(x: 8, y: y, width: width - 16, height: height)
          singleImageView.downloadImageFrom(link: photo.minimumSize.url,
                                            contentMode: UIView.ContentMode.scaleToFill)
        }
        
        y += height + 14
      }
    } else {
      if !measureOnly {
        singleImageView.cancelDownload()
        singleImageView.image = nil
        singleImageView.isHidden = true
      }
    }
    
    if !measureOnly {
      likesImageView.frame = CGRect(x: 24, y: y, width: 24, height: 24)
      likesCountLabel.frame = CGRect(x: 53, y: y + 3, width: 50, height: 17)
      likesCountLabel.text = post.likes.toShortString()
      commentsImageView.frame = CGRect(x: 110, y: y, width: 24, height: 24)
      commentsCountLabel.frame = CGRect(x: 139, y: y + 3, width: 50, height: 17)
      commentsCountLabel.text = post.comments.toShortString()
      repostsImageView.frame = CGRect(x: 195, y: y, width: 24, height: 24)
      repostsCountLabel.frame = CGRect(x: 224, y: y + 3, width: 50, height: 17)
      repostsCountLabel.text = post.reposts.toShortString()
      viewsImageView.frame = CGRect(x: width - 73, y: y + 2, width: 20, height: 20)
      viewsCountLabel.frame = CGRect(x: width - 51, y: y + 6, width: 43, height: 11)
      viewsCountLabel.text = post.views.toShortString()
    }
    
    y += 34
    
    if !measureOnly {
      backgroundImageView.frame = CGRect(x: -10, y: 0, width: width + 20, height: y + 18)
    }
    
    return y + 12
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
