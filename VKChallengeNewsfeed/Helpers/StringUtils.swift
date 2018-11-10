//
//  StringUtils.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit

extension Int {
  func toShortString() -> String {
    if self > 10000000 || (self > 1000000 && (self / 100000) % 10 == 0) {
      return String(self / 1000000) + "M";
    } else
    if self > 1000000 {
      return String(Float(self / 100000) / 10) + "M";
    } else
    if self > 10000 || (self > 1000 && (self / 100) % 10 == 0) {
      return String(self / 1000) + "K";
    } else
    if self > 1000 {
      return String(Float(self / 100) / 10) + "K";
    } else {
      return String(self);
    }
  }
  
  func toPluralString(_ cs: [String]) -> String {
    let n = self % 100;
    if ((n % 10 == 0) || (n % 10 > 4) || (n > 4 && n < 21) || (n % 1 != 0)) {
      return cs[2];
    } else
      if (n % 10 == 1) {
        return cs[0];
      } else {
        return cs[1];
    }
  }
  
  func toRelativeDateString() -> String {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "H:mm"
    
    let calendar = Calendar.current
    let date = Date(timeIntervalSince1970: TimeInterval(self))
    let now = Date()
    let day = calendar.component(Calendar.Component.day, from: date)
    let month = calendar.component(Calendar.Component.month, from: date)
    let months = ["янв", "фев", "мар", "апр", "май", "июн", "июл", "авг", "сен", "окт", "ноя", "дек"]
    let year = calendar.component(Calendar.Component.year, from: date)
    if calendar.isDateInToday(date) {
      return "сегодня в " + timeFormatter.string(from: date)
    } else
    if calendar.isDateInYesterday(date) {
      return "вчера в " + timeFormatter.string(from: date)
    } else
    if calendar.isDateInTomorrow(date) {
      return "завтра в " + timeFormatter.string(from: date)
    } else
    if year == calendar.component(Calendar.Component.year, from: now) {
      return String(day) + " " + months[month - 1] + " в " + timeFormatter.string(from: date)
    } else {
      return String(day) + " " + months[month - 1] + " " + String(year)
    }
  }
}

extension NSRange {
  public init(_ range:Range<String.Index>) {
    self.init(location: range.lowerBound.encodedOffset,
              length: range.upperBound.encodedOffset -
                range.lowerBound.encodedOffset) }
}

extension String {
  subscript(_ range: NSRange) -> String {
    return (self as NSString).substring(with: range)
  }
}


extension UILabel {
  func calculateMaxLines() -> Int {
    let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
    let charSize = font.lineHeight
    let text = (self.attributedText ?? NSAttributedString()) as NSAttributedString
    let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil)
    let linesRoundedUp = Int(ceil(textSize.height / charSize))
    return linesRoundedUp
  }
}
