//
//  ImageUtils.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit

extension UIImageView {
  override open func awakeFromNib() {
    super.awakeFromNib()
    tintColorDidChange()
  }
}

extension UIImage {
  func resize(toWidth: CGFloat) -> UIImage? {
    if self.size.width == 0 || self.size.height == 0 {
      return self
    }
    return resize(withSize: CGSize(width: toWidth, height: self.size.height * toWidth / self.size.width))
  }
  
  private func resize(withSize size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 1)
    defer { UIGraphicsEndImageContext() }
    draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
