//
//  API.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import Foundation

class API {
  static var token: String? = nil
  
  static func call(method: String,
                   params: [String: String],
                   onCompletion: @escaping (_ response: Any?, _ error: Error?)->()) {
    if API.token == nil {
      onCompletion(nil, NSError(domain: "com.vk.NotAuthorized", code: 0, userInfo: nil))
      return
    }
    
    var request = URLRequest(url: URL(string: "https://api.vk.com/method/" + method)!)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    
    var parametersString = "v=5.87&access_token=" + API.token! + "&"
    for (key, value) in params {
      parametersString += key.description + "=" + value.description + "&"
    }
    request.httpBody = parametersString.data(using: .utf8)
    
    var returnRes: [String: Any] = [:]
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      
      if let error = error {
        onCompletion(nil, error)
      } else {
        guard let data = data else {
          onCompletion(nil, error)
          return
        }
        
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
          do {
            returnRes = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            if let response = returnRes["response"] {
              onCompletion(response, nil)
            } else {
              onCompletion(nil, NSError(domain: "com.vk.APIError", code: 0, userInfo: returnRes))
            }
          } catch let error as NSError {
            onCompletion(nil, error)
          }
        } else {
          onCompletion(nil, error)
        }
      }
    }
    task.resume()
  }
  
  static func execute(code: String, onCompletion: @escaping (_ result: Any?, _ error: Error?)->()) {
    API.call(method: "execute", params: ["code": code], onCompletion: onCompletion)
  }
  
  static func getNewsfeed(startFrom: String?, count: Int, onCompletion: @escaping (_ list: PostList?, _ error: Error?)->()) {
    var params: [String: String] = [
      "filters": "post",
      "fields": "photo_50,photo_100",
      "count": String(count)
    ]
    if startFrom != nil {
      params["start_from"] = startFrom!
    }
    API.call(method: "newsfeed.get", params: params) { (response, error) in
      if let list = response {
        onCompletion(NewsfeedPostList(json: list as! [String: Any]), nil)
      } else {
        onCompletion(nil, error)
      }
    }
  }
  
  static func searchNewsfeed(query: String, startFrom: String?, count: Int,
                             onCompletion: @escaping (_ list: PostList?, _ error: Error?)->()) {
    var params: [String: String] = [
      "q": query,
      "fields": "photo_50,photo_100",
      "count": String(count),
      "extended": "1"
    ]
    if startFrom != nil {
      params["start_from"] = startFrom!
    }
    API.call(method: "newsfeed.search", params: params) { (response, error) in
      if let list = response {
        onCompletion(NewsfeedSearchPostList(query: query, json: list as! [String: Any]), nil)
      } else {
        onCompletion(nil, error)
      }
    }
  }
  
  static func getSelf(fields: [String], onCompletion: @escaping (_ user: User?, _ error: Error?)->()) {
    let params: [String: String] = [
      "fields": fields.joined(separator: ",")
    ]
    API.call(method: "users.get", params: params) { (response, error) in
      if let user = response {
        onCompletion(User(json: user as! [String: Any]), nil)
      } else {
        onCompletion(nil, error)
      }
    }
  }
  
  static func getSelfAndNewsfeed(onCompletion: @escaping (_ user: User?, _ list: PostList?,_ error: Error?)->()) {
    API.execute(code: "return [API.users.get({ fields: \"photo_50,photo_100\" }), API.newsfeed.get({ filters: \"post\", fields: \"photo_50,photo_100\" })];") { (response, error) in
      if let pair = response as? [Any] {
        let user = User(json: (pair[0] as! [Any])[0] as! [String: Any])
        let list = NewsfeedPostList(json: pair[1] as! [String: Any])
        onCompletion(user, list, nil)
      } else {
        onCompletion(nil, nil, error)
      }
    }
  }
}
