//
//  User.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

public class User: Profile {
  public let id: Int
  public var ownerId: Int {
    get {
      return id
    }
  }
  public let photo: String
  public let firstName: String
  public let lastName: String
  public var name: String {
    get {
      return firstName + " " + lastName
    }
  }
  
  init(json: [String: Any]) {
    id = json["id"] as! Int
    photo = json["photo_50"] as! String
    firstName = json["first_name"] as! String
    lastName = json["last_name"] as! String
  }
}
