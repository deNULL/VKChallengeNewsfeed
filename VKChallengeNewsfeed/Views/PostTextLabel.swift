//
//  PostTextLabel.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 10/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit

class PostLayoutManager: NSLayoutManager {
  override func showCGGlyphs(_ glyphs: UnsafePointer<CGGlyph>, positions: UnsafePointer<CGPoint>, count glyphCount: Int, font: UIFont, matrix textMatrix: CGAffineTransform, attributes: [NSAttributedString.Key : Any] = [:], in graphicsContext: CGContext) {
    if let foregroundColor = attributes[NSAttributedString.Key.foregroundColor] as? UIColor {
      graphicsContext.setFillColor(foregroundColor.cgColor)
    }
    super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, matrix: textMatrix, attributes: attributes, in: graphicsContext)
  }
  
  override func drawUnderline(forGlyphRange glyphRange: NSRange, underlineType underlineVal: NSUnderlineStyle, baselineOffset: CGFloat, lineFragmentRect lineRect: CGRect, lineFragmentGlyphRange lineGlyphRange: NSRange, containerOrigin: CGPoint) {
    // No underline
  }
}

class PostTextLabel: UILabel {
  let layoutManager = PostLayoutManager()
  let textContainer = NSTextContainer(size: CGSize.zero)
  var textStorage = NSTextStorage() {
    didSet {
      textStorage.addLayoutManager(layoutManager)
    }
  }
  var onCharacterTapped: ((_ label: UILabel, _ characterIndex: Int) -> Void)?
  
  let tapGesture = UITapGestureRecognizer()
  override var attributedText: NSAttributedString? {
    didSet {
      if let attributedText = attributedText {
        textStorage = NSTextStorage(attributedString: attributedText)
      } else {
        textStorage = NSTextStorage()
      }
    }
  }
  override var lineBreakMode: NSLineBreakMode {
    didSet {
      textContainer.lineBreakMode = lineBreakMode
    }
  }
  
  override var numberOfLines: Int {
    didSet {
      textContainer.maximumNumberOfLines = numberOfLines
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUp()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }
  
  func setUp() {
    isUserInteractionEnabled = true
    layoutManager.addTextContainer(textContainer)
    textContainer.lineFragmentPadding = 0
    textContainer.lineBreakMode = lineBreakMode
    textContainer.maximumNumberOfLines = numberOfLines
    tapGesture.addTarget(self, action: #selector(PostTextLabel.labelTapped(_:)))
    addGestureRecognizer(tapGesture)
  }
  
  func parseText(text: String, query: String?) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 22.0 - 17.25
    
    var str: String = text
    let regex = try? NSRegularExpression(pattern: "\\[([^\\]\\|]+)\\|([^\\]\\|]+)\\]")
    var matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
    var links: [NSRange: String] = [:]
    if matches != nil {
      var diff = 0
      for match in matches! {
        let oldPart = match.range(at: 0)
        let link = match.range(at: 1)
        let newPart = match.range(at: 2)
        
        let range = NSRange(location: oldPart.location - diff, length: newPart.length)
        diff += oldPart.length - newPart.length
        
        links[range] = "https://vk.com/" + str[link]
      }
      
      str = (regex?.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count), withTemplate: "$2"))!
    }
    
    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    matches = detector?.matches(in: str, options: [], range: NSRange(location: 0, length: str.utf16.count))
    if matches != nil {
      for match in matches! {
        links[match.range(at: 0)] = match.url?.absoluteString
      }
    }
    
    let hashtags = try? NSRegularExpression(pattern: "#([A-Z_a-z0-9А-Яа-яёЁ]+)(@[A-Z_a-z0-9]+)?")
    matches = hashtags?.matches(in: str, options: [], range: NSRange(location: 0, length: str.utf16.count))
    if matches != nil {
      for match in matches! {
        let hash = match.range(at: 0)
        links[hash] = str[hash]
      }
    }
    
    let result = NSMutableAttributedString(string: str, attributes: [
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0),
      NSAttributedString.Key.paragraphStyle: paragraphStyle
      ])
    
    for (range, link) in links {
      result.addAttributes([
        .link: link,
        NSAttributedString.Key.foregroundColor: UIColor(red: 0.32, green: 0.55, blue: 0.80, alpha: 1.0),
        NSAttributedString.Key.underlineStyle: 0
      ], range: range)
    }
    attributedText = result
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    textContainer.size = bounds.size
  }
  
  func textOffsetForGlyphRange(glyphRange: NSRange) -> CGPoint {
    var textOffset = CGPoint.zero
    
    let textBounds = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    let paddingHeight = (bounds.size.height - textBounds.size.height) / 2.0
    if paddingHeight > 0 {
      //textOffset.y = paddingHeight
    }
  
    return textOffset;
  }
  
  override func drawText(in rect: CGRect) {
    // Calculate the offset of the text in the view
    let glyphRange = layoutManager.glyphRange(forBoundingRectWithoutAdditionalLayout: rect, in: textContainer)
    let textOffset = textOffsetForGlyphRange(glyphRange: glyphRange)
    
    layoutManager.drawBackground(forGlyphRange: glyphRange, at: textOffset)
    layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: textOffset)
  }
  
  @objc func labelTapped(_ gesture: UITapGestureRecognizer) {
    guard gesture.state == .ended else {
      return
    }
    let locationOfTouch = gesture.location(in: gesture.view)
    let textBoundingBox = layoutManager.usedRect(for: textContainer)
    let textContainerOffset = CGPoint(x: (bounds.width - textBoundingBox.width) / 2 - textBoundingBox.minX,
                                      y: (bounds.height - textBoundingBox.height) / 2 - textBoundingBox.minY)
    let locationOfTouchInTextContainer = CGPoint(x: locationOfTouch.x - textContainerOffset.x, y: locationOfTouch.y - textContainerOffset.y)
    let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                        in: textContainer,  fractionOfDistanceBetweenInsertionPoints: nil)
    
    onCharacterTapped?(self, indexOfCharacter)
  }

}
