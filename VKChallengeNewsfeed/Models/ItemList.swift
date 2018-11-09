//
//  ItemList.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

public protocol ItemList: Collection {
  var nextFrom: String? { get set }
  var loader: ((String?, Int, (Bool, Error?, Self?) -> ()) -> ())? { get set }
  var profiles: ProfileCollection { get set }
  mutating func loadNext(count: Int, onCompletion: (_ error: Error?) -> ())
}
