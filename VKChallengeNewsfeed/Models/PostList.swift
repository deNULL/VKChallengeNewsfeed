//
//  PostList.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

public class PostList: ItemList<Post> {
  override init() {
    super.init()
  }
  
  override init(json: [String: Any]) {
    super.init(json: json)
    let list = json["items"] as! [Any]
    for item in list {
      let post = item as! [String: Any]
      items.append(Post(json: post, profiles: profiles))
    }
  }
}

public class NewsfeedPostList: PostList {
  override func loadItems(count: Int, onCompletion: @escaping (ItemList<Post>?, Error?) -> ()) {
    API.getNewsfeed(startFrom: nextFrom, count: count, onCompletion: onCompletion)
  }
}

public class NewsfeedSearchPostList: NewsfeedPostList {
  let query: String
  init(query: String, json: [String: Any]) {
    self.query = query
    super.init(json: json)
  }
  
  override func loadItems(count: Int, onCompletion: @escaping (ItemList<Post>?, Error?) -> ()) {
    API.searchNewsfeed(query: query, startFrom: nextFrom, count: count, onCompletion: onCompletion)
  }
}
