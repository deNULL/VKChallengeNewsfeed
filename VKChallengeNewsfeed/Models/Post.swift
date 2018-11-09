//
//  Post.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

public class Post {
  let id: Int
  let source: Profile
  let text: String
  let likes: Int
  let comments: Int
  let reposts: Int
  let views: Int
  let date: Int
  let attachments: [Any]
  
  init(json: [String: Any], profiles: ProfileCollection) {
    id = json["post_id"] as! Int
    let sourceId = json["source_id"] as! Int
    source = profiles[sourceId]!
    text = json["text"] as! String
    likes = (json["likes"] as! [String: Any])["count"] as! Int
    comments = (json["comments"] as! [String: Any])["count"] as! Int
    reposts = (json["reposts"] as! [String: Any])["count"] as! Int
    views = (json["views"] as! [String: Any])["count"] as! Int
    date = json["date"] as! Int
    var list: [Any] = []
    if let attachs = json["attachments"] as? [Any] {
      for item in attachs { // Filtering out unsupported attachments
        let attach = item as! [String: Any]
        let type = attach["type"] as! String
        if type == "photo" {
          let photo = Photo(json: attach[type] as! [String: Any], profiles: profiles)
          list.append(photo)
        }
      }
    }
    attachments = list
  }
}
