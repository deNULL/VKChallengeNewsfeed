//
//  DownloadableImageView.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit

class DownloadableImageView: RoundedImageView {
  var currentUrl: String? = nil
  
  func downloadImageFrom(link: String, scaledToWidth: CGFloat?, contentMode: UIView.ContentMode) {
    self.contentMode = contentMode
    ImageManager.instance.download(src: link, scaledToWidth: scaledToWidth, deliverTo: self)
  }
}
