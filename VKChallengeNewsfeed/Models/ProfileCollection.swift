//
//  ProfileCollection.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

public struct ProfileCollection: Collection {
  public typealias DictionaryType = Dictionary<Int, Profile>
  private var dictionary: DictionaryType
  
  init(users: [Any], groups: [Any]) {
    dictionary = [:]
    addUsers(list: users)
    addGroups(list: groups)
  }
  
  //Collection: these are the access methods
  public typealias Indices = DictionaryType.Indices
  public typealias Iterator = DictionaryType.Iterator
  public typealias SubSequence = DictionaryType.SubSequence
  
  public var startIndex: Index { return dictionary.startIndex }
  public var endIndex: DictionaryType.Index { return dictionary.endIndex }
  public subscript(position: Index) -> Iterator.Element { return dictionary[position] }
  public subscript(bounds: Range<Index>) -> SubSequence { return dictionary[bounds] }
  public var indices: Indices { return dictionary.indices }
  public subscript(key: Int) -> Profile? {
    get { return dictionary[key] }
    set { dictionary[key] = newValue }
  }
  public func index(after i: Index) -> Index {
    return dictionary.index(after: i)
  }
  
  //Sequence: iteration is implemented here
  public func makeIterator() -> DictionaryIterator<Int, Profile> {
    return dictionary.makeIterator()
  }
  
  //IndexableBase
  public typealias Index = DictionaryType.Index
  
  public mutating func addUser(user: [String: Any]) {
    self.add(profile: User(json: user))
  }
  
  public mutating func addUsers(list: [Any]) {
    for user in list {
      self.addUser(user: user as! [String: Any])
    }
  }
  
  public mutating func addGroup(group: [String: Any]) {
    self.add(profile: Group(json: group))
  }
  
  public mutating func addGroups(list: [Any]) {
    for group in list {
      self.addGroup(group: group as! [String: Any])
    }
  }
  
  public mutating func add(profile: Profile) {
    self[profile.ownerId] = profile
  }
  
  public mutating func merge(other: ProfileCollection) {
    self.dictionary.merge(other.dictionary) { (oldVal, newVal) -> Profile in
      return newVal
    }
  }
}
