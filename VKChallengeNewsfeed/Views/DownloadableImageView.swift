//
//  DownloadableImageView.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit

class DownloadableImageView: RoundedImageView {
  var downloadTask: URLSessionDataTask? = nil
  
  func downloadImageFrom(link: String, contentMode: UIView.ContentMode) {
    if downloadTask != nil {
      downloadTask!.cancel()
    }
    
    downloadTask = URLSession.shared.dataTask(with: URL(string: link)!) { (data, response, error) in
      DispatchQueue.main.async {
        self.contentMode =  contentMode
        if let data = data { self.image = UIImage(data: data) }
      }
    }
    downloadTask!.resume()
  }
}
