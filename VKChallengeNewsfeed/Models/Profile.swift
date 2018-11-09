//
//  Profile.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

public protocol Profile {
  var id: Int { get }
  var ownerId: Int { get }
  var name: String { get }
  var photo: String { get }
}
