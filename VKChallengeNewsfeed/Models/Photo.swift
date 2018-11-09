//
//  Photo.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

public class Photo {
  let id: Int
  let owner: Profile
  init(json: [String: Any], profiles: ProfileCollection) {
    id = json["id"] as! Int
    let ownerId = json["owner_id"] as! Int
    owner = profiles[ownerId]!
  }
}
