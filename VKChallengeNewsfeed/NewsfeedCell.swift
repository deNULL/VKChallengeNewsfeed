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
  static let USE_DYNAMIC_CAROUSEL_HEIGHT: Bool = false
  static let ALLOW_CAROUSEL_CLIPPING: Bool = false
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var sourceImageView: DownloadableImageView!
  @IBOutlet weak var sourceNameLabel: UILabel!
  @IBOutlet weak var postDateLabel: UILabel!
  @IBOutlet var postTextLabel: PostTextLabel!
  @IBOutlet weak var expandTextLabel: UILabel!
  @IBOutlet weak var singleImageView: DownloadableImageView!
  @IBOutlet weak var galleryContainerView: UIView!
  @IBOutlet weak var galleryScrollView: UIScrollView!
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
  var galleryPendingUrls: [String?] = []
  var delegate: NewsfeedCellDelegate? = nil
  var index: Int = 0
  var post: Post? = nil
  var query: String? = nil
  
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
  
  static let measuringInstance: NewsfeedCell = {
    let cell = NewsfeedCell(frame: .zero)
    cell.postTextLabel = PostTextLabel(frame: .zero)
    return cell
  }()
  
  static func calculateHeight(index: Int, post: Post, state: NewsfeedCellState, width: CGFloat) -> CGFloat {
    return measuringInstance.setupCell(index: index, post: post, state: state, query: nil, width: width, measureOnly: true, stateOnly: false)
  }
  
  static func prefetchImages(forPost post: Post, width: CGFloat) {
    ImageManager.instance.prefetch(src: post.source.photo, scaledToWidth: 36)
    if let attachments = post.attachments as? [Photo] {
      if attachments.count > 0 {
        ImageManager.instance.prefetch(src: attachments[0].minimumSize.url, scaledToWidth: width - 40)
      }
    }
  }
  
  func updateLayout(state: NewsfeedCellState, width: CGFloat) {
    setupCell(index: index, post: post!, state: state, query: query, width: width, measureOnly: false, stateOnly: true)
  }
  
  let LINE: CGFloat = 22.0
  func setupCell(index: Int, post: Post, state: NewsfeedCellState, query: String?, width: CGFloat, measureOnly: Bool, stateOnly: Bool) -> CGFloat {
    if !stateOnly {
      self.index = index
      self.post = post
      self.query = query
    }
    
    var y: CGFloat = 0
  
    if !measureOnly && !stateOnly {
      sourceImageView.downloadImageFrom(link: post.source.photo, scaledToWidth: 36, contentMode: .scaleAspectFit)
      
      sourceNameLabel.text = post.source.name
      sourceNameLabel.frame = CGRect(x: 66, y: 13, width: width - 90, height: 17)
      
      postDateLabel.text = post.date.toRelativeDateString()
      postDateLabel.frame = CGRect(x: 66, y: 31, width: width - 90, height: 14.33)
    }
    
    y += 57.5
    
    if post.text.isEmpty {
      if !measureOnly {
        postTextLabel.isHidden = true
      }
      
      y += 4
    } else {
      if !stateOnly {
        postTextLabel.parseText(text: post.text, query: query, dirty: false)
      }
      
      let postTextFullHeight = postTextLabel.calculateHeight(width: width - 40)
      let postTextLines = Int(ceil(postTextFullHeight / LINE))
      let isExpanded = state.isExpanded || postTextLines <= 8
      let postTextHeight = isExpanded ? postTextFullHeight : (LINE * 6)
      
      if !measureOnly {
        postTextLabel.isHidden = false
        postTextLabel.numberOfLines = isExpanded ? 0 : 6
        // We add paddings (left: 4, right: 4, top: 1, bottom: 2) because we need to draw search highlights
        postTextLabel.frame = CGRect(x: 20 - 4, y: y - 1, width: width - 40 + 8, height: postTextHeight + 3)
      }
      
      y += postTextHeight
      
      if !measureOnly {
        expandTextLabel.isHidden = isExpanded
        if !isExpanded {
          expandTextLabel.frame = CGRect(x: 20, y: y, width: expandTextLabel.frame.width, height: 18)
        }
      }
      
      if !isExpanded {
        y += 18
      }
      
      y += 10.5
    }
    
    if post.attachments.count > 0 { // Swipeable collection of photos
      let photo = (post.attachments[state.selectedPhoto] as! Photo)
      var aspect = max(0.4, min(CGFloat(photo.maximumSize.width) / CGFloat(photo.maximumSize.height), 3.0))
      
      
      
      if post.attachments.count > 1 {
        if !stateOnly {
          for imageView in galleryImageViews {
            ImageManager.instance.cancel(view: imageView)
            imageView.removeFromSuperview()
          }
          galleryImageViews = []
          galleryPendingUrls = []
        }
        
        // Calculate average aspect ratio
        if !NewsfeedCell.USE_DYNAMIC_CAROUSEL_HEIGHT {
          aspect = 0.0
          for photo in post.attachments as! [Photo] {
            aspect += log2(max(0.4, min(CGFloat(photo.maximumSize.width) / CGFloat(photo.maximumSize.height), 3.0)))
          }
          aspect = pow(2.0, aspect / CGFloat(post.attachments.count))
        }
        
        // TODO: how to calculate aspect if it's different for each photo?
        let height = (width - 40) / aspect
        if !measureOnly {
          galleryContainerView.frame = CGRect(x: 8, y: y, width: width - 16, height: height)
          galleryScrollView.frame = CGRect(x: 10, y: 0, width: width - 36, height: height)

          var x: CGFloat = 2
          var i: Int = 0
          for photo in post.attachments as! [Photo] {
            let frame = CGRect(x: x, y: 0, width: width - 40, height: height)
            if !stateOnly {
              let imageView = DownloadableImageView(frame: frame)
              if abs(i - state.selectedPhoto) <= 1 { // First, load only closest photos, all other are not visible anyway
                imageView.downloadImageFrom(link: photo.minimumSize.url, scaledToWidth: width - 40, contentMode: NewsfeedCell.ALLOW_CAROUSEL_CLIPPING ? .scaleAspectFill : .scaleAspectFit)
                galleryPendingUrls.append(nil)
              } else { // Store url to load later
                galleryPendingUrls.append(photo.minimumSize.url)
              }
              imageView.clipsToBounds = true
            
              galleryImageViews.append(imageView)
              galleryScrollView.addSubview(imageView)
            } else {
              galleryImageViews[i].frame = frame
            }
            
            x += 4 + (width - 40)
            i += 1
          }
          galleryScrollView.contentSize = CGSize(width: x - 2, height: height)
          
          x = CGFloat(state.selectedPhoto) * (4 + (width - 40))
          galleryScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        }
        
        y += height + 1
        
        if !measureOnly {
          galleryPageControl.frame = CGRect(x: 8, y: y, width: width - 16, height: 37)
          galleryPageControl.numberOfPages = post.attachments.count
          galleryPageControl.currentPage = state.selectedPhoto
        }
        
        y += 38
        
        if !measureOnly {
          gallerySeparatorView.frame = CGRect(x: 20, y: y - 0.5, width: width - 40, height: 0.5)
        }
        
        y += 10
      } else { // Single image
        if !measureOnly && !stateOnly {
          //ImageManager.instance.cancel(view: singleImageView)
          singleImageView.isHidden = false
        }
        
        let height = (width - 16) / aspect
        if !measureOnly {
          singleImageView.frame = CGRect(x: 8, y: y, width: width - 16, height: height)
          singleImageView.downloadImageFrom(link: photo.minimumSize.url, scaledToWidth: width - 16, contentMode: .scaleAspectFill)
        }
        
        y += height + 14
      }
    } else { // No supported attachments, text only
      if !measureOnly && !stateOnly {
        ImageManager.instance.cancel(view: singleImageView)
        singleImageView.image = nil
        singleImageView.isHidden = true
      }
    }
    
    if !measureOnly {
      likesImageView.frame = CGRect(x: 24, y: y, width: 24, height: 24)
      likesCountLabel.frame = CGRect(x: 53, y: y + 3, width: 50, height: 17)
      likesCountLabel.text = post.likes.toShortString()
      commentsImageView.frame = CGRect(x: 108, y: y, width: 24, height: 24)
      commentsCountLabel.frame = CGRect(x: 137, y: y + 3, width: 50, height: 17)
      commentsCountLabel.text = post.comments.toShortString()
      repostsImageView.frame = CGRect(x: 192, y: y, width: 24, height: 24)
      repostsCountLabel.frame = CGRect(x: 221, y: y + 3, width: 50, height: 17)
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
    //delegate?.selectedPhotoChanged(cell: self, selectedPhoto: Int(round(value)))
    for offs in -1...1 {
      let page = galleryPageControl.currentPage + offs
      if page >= 0 && page < galleryPendingUrls.count && galleryPendingUrls[page] != nil {
        galleryImageViews[page].downloadImageFrom(link: galleryPendingUrls[page]!, scaledToWidth: scrollView.frame.size.width - 4, contentMode: NewsfeedCell.ALLOW_CAROUSEL_CLIPPING ? .scaleAspectFill : .scaleAspectFit)
        galleryPendingUrls[page] = nil
      }
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    delegate?.selectedPhotoChanged(cell: self, selectedPhoto: galleryPageControl.currentPage)
  }
  
  @objc func tapExpand() {
    delegate?.expandedText(cell: self)
  }
}
