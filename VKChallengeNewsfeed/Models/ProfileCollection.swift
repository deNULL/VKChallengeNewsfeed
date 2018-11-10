//
//  ProfileCollection.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

public class ProfileCollection {
  private var dictionary: Dictionary<Int, Profile>
  
  init() {
    dictionary = [:]
  }
  
  init(users: [Any]?, groups: [Any]?) {
    dictionary = [:]
    if let users = users {
      addUsers(list: users)
    }
    if let groups = groups {
      addGroups(list: groups)
    }
  }
  
  public subscript(id: Int) -> Profile? {
    get {
      return dictionary[id]
    }
    set {
      dictionary[id] = newValue
    }
  }
  
  public func addUser(user: [String: Any]) {
    self.add(profile: User(json: user))
  }
  
  public func addUsers(list: [Any]) {
    for user in list {
      self.addUser(user: user as! [String: Any])
    }
  }
  
  public func addGroup(group: [String: Any]) {
    self.add(profile: Group(json: group))
  }
  
  public func addGroups(list: [Any]) {
    for group in list {
      self.addGroup(group: group as! [String: Any])
    }
  }
  
  public func add(profile: Profile) {
    self[profile.ownerId] = profile
  }
  
  public func merge(other: ProfileCollection) {
    self.dictionary.merge(other.dictionary) { (oldVal, newVal) -> Profile in
      return newVal
    }
  }
}
