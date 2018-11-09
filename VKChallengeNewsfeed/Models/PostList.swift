//
//  PostList.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

public struct PostList: ItemList {
  public typealias ArrayType = Array<Post>
  private var array: ArrayType
  
  init(json: [String: Any], loader: @escaping (String?, Int, @escaping (Bool, Error?, PostList?) -> ()) -> ()) {
    array = []
    self.loader = loader
    profiles = ProfileCollection(users: json["users"] as! [Any], groups: json["groups"] as! [Any])
    let items = json["items"] as! [Any]
    for item in items {
      let post = item as! [String: Any]
      array.append(Post(json: post, profiles: profiles))
    }
    nextFrom = json["next_from"] as? String
  }
  
  //Collection: these are the access methods
  public typealias Indices = ArrayType.Indices
  public typealias Iterator = ArrayType.Iterator
  public typealias SubSequence = ArrayType.SubSequence
  
  public var startIndex: Index { return array.startIndex }
  public var endIndex: ArrayType.Index { return array.endIndex }
  public subscript(position: Index) -> Iterator.Element { return array[position] }
  public subscript(bounds: Range<Index>) -> SubSequence { return array[bounds] }
  public var indices: Indices { return array.indices }
  public subscript(key: Int) -> Post? {
    get { return array[key] }
    set { array[key] = newValue as! Post }
  }
  public func index(after i: Index) -> Index {
    return array.index(after: i)
  }
  
  //Sequence: iteration is implemented here
  public func makeIterator() -> IndexingIterator<ArrayType> {
    return array.makeIterator()
  }
  
  //IndexableBase
  public typealias Index = ArrayType.Index
  
  public var nextFrom: String?
  public var loader: ((String?, Int, @escaping (Bool, Error?, PostList?) -> ()) -> ())?
  public var profiles: ProfileCollection
  
  public mutating func loadNext(count: Int, onCompletion: @escaping (_ error: Error?) -> ()) {
    if loader != nil && nextFrom != nil {
      loader!(nextFrom!, count) { (success, error, list) in
        if success {
          self.array.append(contentsOf: list!.array as [Post])
          self.profiles.merge(other: list!.profiles)
          self.nextFrom = list!.nextFrom
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
