//
//  ImageManager.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 11/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit

class ImageManager {
  static let instance = ImageManager()
  var images: [String: UIImage] = [:]
  var pending: [String: URLSessionDataTask] = [:]
  var loading: [String: DispatchWorkItem] = [:]
  var views: [DownloadableImageView] = []
  var waiting: [String: Int] = [:]
  
  func currentLoad() -> Int {
    return pending.count + loading.count
  }
  
  // Clear cache
  func drop() {
    images.removeAll()
  }
  
  // Image should be delivered as soon as possible
  func download(src: String, scaledToWidth: CGFloat?, deliverTo: DownloadableImageView) {
    // Already displayed here
    if deliverTo.currentUrl == src {
      return
    }
    
    if deliverTo.currentUrl != nil {
      cancel(src: deliverTo.currentUrl!)
    }
    deliverTo.currentUrl = src
    
    // Already in cache
    if let image = images[src] {
      deliverTo.image = image
      return
    }
    
    deliverTo.image = nil
    
    // Ensure that view will be notified when the image is ready
    if !views.contains(deliverTo) {
      views.append(deliverTo)
      
      if waiting[src] == nil {
        waiting[src] = 1
      } else {
        waiting[src] = waiting[src]! + 1
      }
    }
    
    // Already waiting for it
    if pending[src] != nil || loading[src] != nil {
      return
    }
    
    addTask(src: src, scaledToWidth: scaledToWidth)
  }
  
  // Image will probably be needed soon
  func prefetch(src: String, scaledToWidth: CGFloat?) {
    // Already in cache
    if images[src] != nil {
      return
    }
    
    // Already waiting for it
    if pending[src] != nil || loading[src] != nil {
      return
    }
    
    addTask(src: src, scaledToWidth: scaledToWidth)
  }
  
  func addTask(src: String, scaledToWidth: CGFloat?) {
    let downloadTask = URLSession.shared.dataTask(with: URL(string: src)!) { (data, response, error) in
      if let data = data {
        let full = UIImage(data: data)
        let resized = scaledToWidth == nil ? full : full?.resize(toWidth: scaledToWidth! * UIScreen.main.scale)
        if let resized = resized {
          self.images[src] = resized
          self.notifyViews(src: src, image: resized)
        } else {
          self.notifyViews(src: src, image: nil)
        }
      } else {
        self.notifyViews(src: src, image: nil)
      }
    }
    pending[src] = downloadTask
    downloadTask.resume()
  }
  
  func notifyViews(src: String, image: UIImage?) {
    var i = 0
    var update: [DownloadableImageView] = []
    while i < views.count {
      if views[i].currentUrl == src {
        update.append(views[i])
        views.remove(at: i)
      } else {
        i += 1
      }
    }
    
    if update.count > 0 {
      let item = DispatchWorkItem(block: {
        for view in update {
          view.image = image
          if image == nil {
            view.currentUrl = nil
          }
        }
        self.loading[src] = nil
      })
      loading[src] = item
      pending[src] = nil
      DispatchQueue.main.async(execute: item)
    } else {
      pending[src] = nil
    }
  }
  
  // Image is no longer needed
  func cancel(src: String) {
    var count = waiting[src] ?? 1
    count -= 1
    if count > 0 {
      waiting[src] = count
    } else {
      waiting[src] = nil
      if let task = pending[src] {
        task.cancel()
        pending[src] = nil
      }
      
      if let item = loading[src] {
        item.cancel()
        loading[src] = nil
      }
    }
  }
  
  func cancel(view: DownloadableImageView) {
    if view.currentUrl != nil {
      cancel(src: view.currentUrl!)
      view.currentUrl = nil
    }
    
    var i = 0
    while i < views.count {
      if views[i] == view {
        views.remove(at: i)
      } else {
        i += 1
      }
    }
  }
}

