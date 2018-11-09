//
//  NewsfeedViewController.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit
import VK_ios_sdk


class NewsfeedViewController: UITableViewController, VKSdkDelegate, VKSdkUIDelegate {
  var me: User? = nil
  var feed: PostList = PostList(loadNext: nil)

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let sdkInstance = VKSdk.initialize(withAppId: "6746103")
    sdkInstance?.register(self)
    sdkInstance?.uiDelegate = self
    
    

    VKSdk.wakeUpSession(["friends", "wall"]) { (state, error) in
      if (state == VKAuthorizationState.authorized) {
        API.token = VKSdk.accessToken()?.accessToken
        self.initNewsfeed()
      } else {
        VKSdk.authorize(["friends", "wall"])
      }
    }
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  func vkSdkShouldPresent(_ controller: UIViewController!) {
    present(controller, animated: true, completion: nil)
  }
  
  func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
    // TODO: more informative alert, generic error method
    let alert = UIAlertController(title: "Ошибка", message: "Капча введена неверно", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    self.present(alert, animated: true, completion: nil)
  }
  
  func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
    if let token = result.token {
      API.token = token.accessToken
      initNewsfeed()
    } else {
      // TODO: more informative alert, generic error method
      let alert = UIAlertController(title: "Ошибка", message: "Не удалось войти", preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func vkSdkUserAuthorizationFailed() {
    // TODO: more informative alert, generic error method
    let alert = UIAlertController(title: "Ошибка", message: "Не удалось войти", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    self.present(alert, animated: true, completion: nil)
  }
  
  func isSearching() -> Bool {
    return false
  }
  
  func initNewsfeed() {
    API.execute(code: "return [API.users.get(), API.newsfeed.get()];") { (success, error, response) in
      // TODO: add error handling
      if let r = response as? [Any] {
        self.me = r[0]
        self.updateFeed(response: r[1] as! [String: Any], replace: true)
      }
    }
  }
  
  func loadMore() {
    if nextFrom == nil {
      return
    }
    
    if isSearching() {
      API.searchNewsfeed(query: "", startFrom: nextFrom) { (success, error, response) in
        // TODO: add error handling
        self.updateFeed(response: response as! [String: Any], replace: false)
      }
    } else {
      API.getNewsfeed(startFrom: nextFrom) { (success, error, response) in
        // TODO: add error handling
        self.updateFeed(response: response as! [String: Any], replace: false)
      }
    }
  }
  
  func updateFeed(response: [String: Any], replace: Bool) {
    if replace {
      feed = response["items"] as! [Any]
      profiles = [:] // Reset storage to prevent eating up memory
    } else {
      feed.append(contentsOf: response["items"] as! [Any])
    }
    nextFrom = response["next_from"] as? String
    
    // Store new users/groups
    if let users = response["profiles"] as? [Any] {
      for item in users {
        let user = item as! [String: Any]
        let id = user["id"] as! Int
        profiles[id] = user
      }
    }
    if let groups = response["groups"] as? [Any] {
      for item in groups {
        let group = item as! [String: Any]
        let id = group["id"] as! Int
        profiles[-id] = group
      }
    }
  }

  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return feed.count
  }

  /*
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

      // Configure the cell...

      return cell
  }
  */

  /*
  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      // Return false if you do not want the specified item to be editable.
      return true
  }
  */

  /*
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
          // Delete the row from the data source
          tableView.deleteRows(at: [indexPath], with: .fade)
      } else if editingStyle == .insert {
          // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
      }
  }
  */

  /*
  // Override to support rearranging the table view.
  override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

  }
  */

  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
      // Return false if you do not want the item to be re-orderable.
      return true
  }
  */

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destination.
      // Pass the selected object to the new view controller.
  }
  */
}
