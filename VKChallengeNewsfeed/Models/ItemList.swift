//
//  ItemList.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

public class ItemList<ItemType> {
  var items: [ItemType]
  var nextFrom: String?
  var profiles: ProfileCollection
  
  init() {
    items = []
    profiles = ProfileCollection() 
    nextFrom = nil
  }
  
  init(json: [String: Any]) {
    items = []
    profiles = ProfileCollection(users: json["profiles"] as! [Any], groups: json["groups"] as! [Any])
    nextFrom = json["next_from"] as? String
  }
  
  func loadItems(count: Int, onCompletion: @escaping (_ list: ItemList<ItemType>?, _ error: Error?) -> ()) {
    // Child classes should override this method with calls to actual APIs
  }
  
  // Reload in-place
  func reload(count: Int, onCompletion: @escaping (_ error: Error?) -> ()) {
    loadItems(count: count) { (newList, error) in
      if let list = newList {
        self.items = list.items
        self.profiles = list.profiles
        self.nextFrom = list.nextFrom
        onCompletion(nil)
      } else {
        onCompletion(error)
      }
    }
  }
  
  // Load new items and append at the end
  func loadNext(count: Int, onCompletion: @escaping (_ error: Error?) -> ()) {
    if nextFrom != nil {
      loadItems(count: count) { (newList, error) in
        if let list = newList {
          self.items.append(contentsOf: list.items)
          self.profiles.merge(other: list.profiles)
          self.nextFrom = list.nextFrom
          onCompletion(nil)
        } else {
          onCompletion(error)
        }
      }
    } else {
      onCompletion(nil)
    }
  }
}
