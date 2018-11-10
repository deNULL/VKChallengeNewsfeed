//
//  Group.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

public class Group: Profile {
  public let id: Int!
  public var ownerId: Int! {
    get {
      return -id
    }
  }
  public let photo: String!
  public let name: String!
  
  init(json: [String: Any]) {
    id = json["id"] as? Int
    photo = json["photo_50"] as? String
    name = json["name"] as? String
  }
}
