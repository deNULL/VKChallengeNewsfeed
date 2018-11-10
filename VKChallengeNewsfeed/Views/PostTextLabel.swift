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
  
  override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
    
    textStorage?.enumerateAttribute(NSAttributedString.Key.backgroundColor, in: glyphsToShow, options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired, using: { (value, range, stop) in
      if value != nil {
        let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        let container = self.textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil)
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.translateBy(x: origin.x, y: origin.y)
        (value as? UIColor)?.setFill()
        let rect = self.boundingRect(forGlyphRange: glyphRange, in: container!);
        
        //UIBezierPath with rounded
        let path = UIBezierPath(roundedRect:
          CGRect(x: rect.minX - 4, y: rect.minY - 1, width: rect.width + 8, height: 22), cornerRadius: 4)
        path.fill()
        context?.restoreGState()
      }
    })
  }
  
  /*override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
    
  }*/
  
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
      textStorage.removeLayoutManager(layoutManager)
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
  
  func parseText(text: String, query: String?, dirty: Bool) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 4.0
    
    var str: String = text
    let regex = try? NSRegularExpression(pattern: "\\[([^\\]\\|]+)\\|([^\\]\\|]+)\\]")
    
    if dirty {
      // In case we are just calculating text height, there's no need for coloring
      str = (regex?.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count), withTemplate: "$2"))!
      let result = NSMutableAttributedString(string: str, attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0),
        NSAttributedString.Key.paragraphStyle: paragraphStyle
      ])
      attributedText = result
      return
    }
    
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
    
    if let query = query {
      let words = try? NSRegularExpression(pattern: "([A-Za-z0-9_-А-Яа-яЁё]{2,})")
      matches = words?.matches(in: query, options: [], range: NSRange(location: 0, length: query.utf16.count))
      if matches != nil && matches!.count > 0 {
        var words: [String] = []
        for match in matches! {
          let word = query[match.range(at: 0)]
          words.append(word)
        }
        let pattern = "(^|[^A-Za-z0-9_А-Яа-яЁё-])((" + words.joined(separator: "|") + ")" + "[A-Za-z0-9_А-Яа-яЁё-]{0,3})" + "($|[^A-Za-z0-9_А-Яа-яЁё-])"
        let search = try? NSRegularExpression(pattern: pattern, options: [NSRegularExpression.Options.caseInsensitive, NSRegularExpression.Options.anchorsMatchLines])
        matches = search?.matches(in: str, options: [], range: NSRange(location: 0, length: str.utf16.count))
        
        for match in matches! {
          let range = match.range(at: 2)
          
          result.addAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(red:0.75, green:0.53, blue:0.16, alpha:1.0),
            NSAttributedString.Key.backgroundColor: UIColor(red:1.00, green:0.63, blue:0.00, alpha:0.12)
          ], range: range)
        }
      }
    }
    attributedText = result
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    textContainer.size = bounds.size
  }
  
  override func drawText(in rect: CGRect) {
    // Calculate the offset of the text in the view
    let glyphRange = layoutManager.glyphRange(for: textContainer)
    
    layoutManager.drawBackground(forGlyphRange: glyphRange, at: .zero)
    layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: .zero)
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
