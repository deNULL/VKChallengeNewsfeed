//
//  Photo.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit

public struct PhotoSize {
  let url: String
  let width: Int
  let height: Int
}

public class Photo {
  let id: Int!
  let owner: Profile?
  let minimumSize: PhotoSize
  let maximumSize: PhotoSize
  
  init(json: [String: Any], profiles: ProfileCollection) {
    id = json["id"] as? Int
    if let ownerId = json["owner_id"] as? Int {
      owner = profiles[ownerId]
    } else {
      owner = nil
    }
    
    let screenWidth = UIScreen.main.bounds.width * UIScreen.main.scale
    var minSize: PhotoSize? = nil
    var maxSize: PhotoSize? = nil
    
    if let sizes = json["sizes"] as? [Any] {
      var maxw = 0
      var minw = 100000
      for size in sizes {
        let sz = size as! [String: Any]
        let width = sz["width"] as! Int
        
        maxw = max(maxw, width)
        if CGFloat(width) >= screenWidth * 0.8 { // We can allow upscaling ~20% smaller images for better performance
          minw = min(minw, width)
        }
      }
      
      for size in sizes {
        let sz = size as! [String: Any]
        let url = sz["url"] as! String
        let width = sz["width"] as! Int
        let height = sz["height"] as! Int
        
        if width == minw {
          minSize = PhotoSize(url: url, width: width, height: height)
        }
        if width == maxw {
          maxSize = PhotoSize(url: url, width: width, height: height)
        }
      }
    }
    
    if maxSize == nil {
      minimumSize = PhotoSize(url: "", width: 1, height: 1)
      maximumSize = minimumSize
      return
    }
    
    minimumSize = minSize == nil ? maxSize! : minSize!
    maximumSize = maxSize!
  }
}
