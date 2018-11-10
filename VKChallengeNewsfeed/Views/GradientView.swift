//
//  GradientTableView.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit

class GradientView: UIView {
  @IBInspectable
  var startColor: UIColor = UIColor(red: 0.97, green: 0.98, blue: 0.98, alpha: 1.0)
  //var startColor: UIColor = .red
  
  @IBInspectable
  var endColor: UIColor = UIColor(red: 0.92, green: 0.93, blue: 0.94, alpha: 1.0)
  //var endColor: UIColor = .black
  
  private let gradientLayerName = "Gradient"
  
  override func layoutSubviews() {
    super.layoutSubviews()
    setupGradient()
  }
  
  private func setupGradient() {
    backgroundColor = startColor
    var gradient: CAGradientLayer? = window?.layer.sublayers?.first { $0.name == gradientLayerName } as? CAGradientLayer
    if gradient == nil {
      gradient = CAGradientLayer()
      gradient?.name = gradientLayerName
      window?.layer.addSublayer(gradient!)
    }
    gradient?.frame = bounds
    gradient?.colors = [startColor.cgColor, endColor.cgColor]
    gradient?.zPosition = -1
  }
}
