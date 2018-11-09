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
