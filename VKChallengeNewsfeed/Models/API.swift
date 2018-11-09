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
                   onCompletion: @escaping (_ success: Bool, _ error: Error?, _ result: Any?)->()) {
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
        onCompletion(false, error, nil)
      } else {
        guard let data = data else {
          onCompletion(false, error, nil)
          return
        }
        
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
          do {
            returnRes = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            if let response = returnRes["response"] {
              onCompletion(true, nil, response)
            } else {
              onCompletion(false, NSError(domain: "com.vk.APIError", code: 0, userInfo: returnRes), nil)
            }
          } catch let error as NSError {
            onCompletion(false, error, nil)
          }
        } else {
          onCompletion(false, error, nil)
        }
      }
    }
    task.resume()
  }
  
  static func execute(code: String, onCompletion: @escaping (_ success: Bool, _ error: Error?, _ result: Any?)->()) {
    API.call(method: "execute", params: ["code": code], onCompletion: onCompletion)
  }
  
  static func getNewsfeed(startFrom: String?, count: Int, onCompletion: @escaping (_ success: Bool, _ error: Error?, _ list: PostList?)->()) {
    var params: [String: String] = ["count": String(count)]
    if startFrom != nil {
      params["start_from"] = startFrom!
    }
    API.call(method: "newsfeed.get", params: params, onCompletion: onCompletion as! (Bool, Error?, Any?) -> ())
  }
  
  static func searchNewsfeed(query: String, startFrom: String?, count: Int,
                             onCompletion: @escaping (_ success: Bool, _ error: Error?, _ list: PostList?)->()) {
    var params: [String: String] = ["q": query, "count": String(count)] 
    if startFrom != nil {
      params["start_from"] = startFrom!
    }
    API.call(method: "newsfeed.search", params: params) { (success, error, response) in
      if success {
        let list = PostList(json: response as! [String: Any], loader: { (nextFrom, count, onCompletion) in
          API.searchNewsfeed(query: query, startFrom: nextFrom, count: count, onCompletion: onCompletion)
        })
        onCompletion(success, nil, list)
      } else {
        onCompletion(success, error, nil)
      }
    }
  }
  
  static func getSelf(fields: [String], onCompletion: @escaping (_ success: Bool, _ error: Error?, _ user: User?)->()) {
    let params: [String: String] = ["fields": fields.joined(separator: ",")]
    API.call(method: "users.get", params: params) { (success, error, response) in
      if success {
        let user = User(json: response as! [String: Any])
        onCompletion(success, nil, user)
      } else {
        onCompletion(success, error, nil)
      }
    }
  }
  
  static func getSelfAndNewsfeed(onCompletion: @escaping (_ success: Bool, _ error: Error?, _ user: User?, _ list: PostList?)->()) {
    API.execute(code: "return [API.users.get(), API.newsfeed.get()];") { (success, error, response) in
      if success {
        let pair = response as! [Any]
        let user = User(json: pair[0] as! [String: Any])
        let list = PostList(json: pair[1] as! [String: Any], loader: API.getNewsfeed)
        onCompletion(success, nil, user, list)
      } else {
        onCompletion(success, error, nil, nil)
      }
    }
  }
}
