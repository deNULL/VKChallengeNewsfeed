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
  var feed: PostList = PostList()
  var cells: [NewsfeedCellState] = []
  @IBOutlet weak var itemsCountLabel: UILabel!
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
  @IBOutlet weak var userpicImageView: DownloadableImageView!
  @IBOutlet weak var footerImageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let sdkInstance = VKSdk.initialize(withAppId: "6746103")
    sdkInstance?.register(self)
    sdkInstance?.uiDelegate = self
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  override func viewDidAppear(_ animated: Bool) {
    VKSdk.wakeUpSession(["friends", "wall"]) { (state, error) in
      if (state == VKAuthorizationState.authorized) {
        API.token = VKSdk.accessToken()?.accessToken
        self.initNewsfeed()
      } else {
        VKSdk.authorize(["friends", "wall"])
      }
    }
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
    itemsCountLabel.isHidden = true
    loadingIndicator.isHidden = false
    API.getSelfAndNewsfeed { (user, list, error) in
      if user != nil && list != nil {
        self.me = user!
        self.feed = list!
        DispatchQueue.main.async {
          self.userpicImageView.downloadImageFrom(link: user!.photo, contentMode: UIView.ContentMode.scaleToFill)
        }
        self.updateCells(reset: true)
      } else {
        // TODO: add error handling
      }
    }
  }
  
  func updateCells(reset: Bool) {
    if reset {
      cells = []
    }
    while cells.count < feed.items.count {
      cells.append(NewsfeedCellState(isExpanded: false, selectedPhoto: 0))
    }
    
    DispatchQueue.main.async {
      self.itemsCountLabel.text =
        String(self.feed.items.count) + " " +
        self.getPlural(m: self.feed.items.count, cs: ["запись", "записи", "записей"]);
      self.itemsCountLabel.isHidden = false
      self.loadingIndicator.isHidden = true
      
      self.footerImageView.isHidden = self.feed.items.count == 0
      
      self.tableView.reloadData()
    }
  }
  
  func getPlural(m: Int, cs: [String]) -> String {
    let n = m % 100;
    if ((n % 10 == 0) || (n % 10 > 4) || (n > 4 && n < 21) || (n % 1 != 0)) {
      return cs[2];
    } else
    if (n % 10 == 1) {
      return cs[0];
    } else {
      return cs[1];
    }
  }
  
  
  
  func loadMore() {
    self.feed.loadNext(count: 30) { (error) in
      if let err = error {
        // TODO: error handling
      }
      // TODO: redraw
      self.updateCells(reset: false)
    }
  }

  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return feed.items.count
  }

  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Post", for: indexPath) as! NewsfeedCell
    cell.setupCell(post: feed.items[indexPath.row], state: cells[indexPath.row])
    return cell
  }
  
  @IBAction func handleRefresh(_ sender: Any) {
    if refreshControl!.isRefreshing {
      feed.reload(count: 30) { (error) in
        DispatchQueue.main.async {
          self.refreshControl?.endRefreshing()
        }
        self.updateCells(reset: true)
      }
    }
  }
  
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
