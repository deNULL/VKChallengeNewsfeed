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
  let owner: Profile
  let attachments: [Any]
  
  init(json: [String: Any], profiles: ProfileCollection) {
    id = json["id"] as! Int
    let ownerId = json["owner_id"] as! Int
    owner = profiles[ownerId]!
    let attachs = json["attachs"] as! [Any]
    var list: [Any] = []
    for item in attachs { // Filtering out unsupported attachments
      let attach = item as! [String: Any]
      let type = attach["type"] as! String
      if type == "photo" {
        let photo = Photo(json: attach[type] as! [String: Any], profiles: profiles)
        list.append(photo)
      }
    }
    attachments = list
  }
}
