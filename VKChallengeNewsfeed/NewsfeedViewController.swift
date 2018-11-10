//
//  NewsfeedViewController.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit
import VK_ios_sdk

class NewsfeedViewController: UITableViewController, VKSdkDelegate, VKSdkUIDelegate, NewsfeedCellDelegate {
  
  var me: User? = nil
  var feed: PostList = PostList()
  var cells: [NewsfeedCellState] = []
  var isSearching: Bool = false
  @IBOutlet weak var itemsCountLabel: UILabel!
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
  @IBOutlet weak var userpicImageView: DownloadableImageView!
  @IBOutlet weak var footerImageView: UIImageView!
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var searchContainer: RoundedView!
  
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
    let app = UIApplication.shared.delegate as! AppDelegate
    app.window!.bringSubviewToFront(app.statusBackdropView)
    
    searchTextField.attributedPlaceholder =
      NSAttributedString(string: "Поиск",
                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:0.51, green:0.55, blue:0.60, alpha:1.0)])
 
    
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
  
  func getSearchQuery() -> String? {
    if let query = searchTextField.text {
      if !query.isEmpty {
        return query
      }
    }
    return nil
  }
  
  func initNewsfeed() {
    itemsCountLabel.isHidden = true
    loadingIndicator.startAnimating()
    API.getSelfAndNewsfeed { (user, list, error) in
      if user != nil && list != nil {
        self.me = user!
        DispatchQueue.main.async {
          self.userpicImageView.downloadImageFrom(link: user!.photo, contentMode: UIView.ContentMode.scaleToFill)
        }
        self.updateCells(list: list!, reset: true)
      } else {
        // TODO: add error handling
      }
    }
  }
  
  func updateCells(list: PostList, reset: Bool) {
    DispatchQueue.main.async {
      self.feed = list
      
      if reset {
        self.cells = []
      }
      while self.cells.count < self.feed.items.count {
        self.cells.append(NewsfeedCellState(isExpanded: false, selectedPhoto: 0))
      }
      
      self.itemsCountLabel.text =
        String(self.feed.items.count) + " " +
        self.feed.items.count.toPluralString(["запись", "записи", "записей"]);
      self.itemsCountLabel.isHidden = false
      self.loadingIndicator.stopAnimating()
      
      self.footerImageView.isHidden = self.feed.items.count == 0
      
      self.tableView.reloadData()
    }
  }
  
  func loadMore() {
    loadingIndicator.startAnimating()
    itemsCountLabel.isHidden = true
    self.feed.loadNext(count: 30) { (error) in
      if let err = error {
        // TODO: error handling
      }
      // TODO: redraw
      self.updateCells(list: self.feed, reset: false)
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
    if indexPath.row >= feed.items.count {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Post", for: indexPath) as! NewsfeedCell
      cell.delegate = self
      return cell
    }
    let post = feed.items[indexPath.row]
    let isGallery = post.attachments.count > 1
    let cell = tableView.dequeueReusableCell(withIdentifier: isGallery ? "PostGallery" : "Post", for: indexPath) as! NewsfeedCell
    cell.delegate = self
    cell.setupCell(
      index: indexPath.row,
      post: post,
      state: cells[indexPath.row],
      query: getSearchQuery(),
      width: tableView.bounds.width,
      measureOnly: false,
      stateOnly: false
    )
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return NewsfeedCell.calculateHeight(
      index: indexPath.row,
      post: feed.items[indexPath.row],
      state: cells[indexPath.row],
      width: tableView.bounds.width
    )
  }
  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return NewsfeedCell.calculateHeight(
      index: indexPath.row,
      post: feed.items[indexPath.row],
      state: cells[indexPath.row],
      width: tableView.bounds.width
    )
  }
  
  func selectedPhotoChanged(cell: NewsfeedCell, selectedPhoto: Int) {
    tableView.beginUpdates()
    cells[cell.index].selectedPhoto = selectedPhoto
    tableView.endUpdates()
    
    UIView.beginAnimations(nil, context: nil)
    cell.updateLayout(state: cells[cell.index], width: tableView.frame.width)
    UIView.commitAnimations()
  }
  
  func expandedText(cell: NewsfeedCell) {
    tableView.beginUpdates()
    cells[cell.index].isExpanded = true
    tableView.reloadRows(at: [IndexPath(row: cell.index, section: 0)], with: UITableView.RowAnimation.automatic)
    tableView.endUpdates()
    
    //UIView.beginAnimations(nil, context: nil)
    //cell.updateLayout(state: cells[cell.index], width: tableView.frame.width)
    //UIView.commitAnimations()
  }
  
  func tappedLink(link: String) {
    if link.prefix(1) == "#" { // Hashtag: search for it
      searchTextField.text = link
      tableView.setContentOffset(.zero, animated: true)
      // TODO: call search
    } else {
      guard let url = URL(string: link) else { return }
      UIApplication.shared.openURL(url)
    }
  }
  
  @IBAction func handleRefresh(_ sender: Any) {
    if refreshControl!.isRefreshing {
      feed.reload(count: 30) { (error) in
        DispatchQueue.main.async {
          self.refreshControl?.endRefreshing()
        }
        self.updateCells(list: self.feed, reset: true)
      }
    }
  }
  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let app = UIApplication.shared.delegate as! AppDelegate
    app.statusBackdropView.alpha = scrollView.contentOffset.y / 40.0;
  }
  
  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    searchTextField.resignFirstResponder()
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if Float(indexPath.row) >= Float(feed.items.count - 1) * 0.9 && feed.nextFrom != nil && !feed.isLoading {
      loadMore()
    }
  }
  
  func searchFor(text: String?) {
    itemsCountLabel.isHidden = true
    loadingIndicator.startAnimating()
    if let query = text {
      if query.count > 0 {
        API.searchNewsfeed(query: query, startFrom: nil, count: 30) { (list, error) in
          if list != nil {
            self.updateCells(list: list!, reset: true)
          }
        }
      } else {
        API.getNewsfeed(startFrom: nil, count: 30) { (list, error) in
          if list != nil {
            self.updateCells(list: list!, reset: true)
          }
        }
      }
    }
  }
  
  @IBAction func changedQuery(_ sender: UITextField) {
    let nowSearching = sender.text != nil && !sender.text!.isEmpty
    if nowSearching != isSearching {
      isSearching = nowSearching
      
      UIView.beginAnimations(nil, context: nil)
      if isSearching {
        searchContainer.frame = CGRect(
          x: searchContainer.frame.minX,
          y: searchContainer.frame.minY,
          width: searchContainer.frame.width + 48,
          height: searchContainer.frame.height)
        userpicImageView.frame = CGRect(
          x: userpicImageView.frame.minX + 48,
          y: userpicImageView.frame.minY,
          width: userpicImageView.frame.width,
          height: userpicImageView.frame.height)
      } else {
        searchContainer.frame = CGRect(
          x: searchContainer.frame.minX,
          y: searchContainer.frame.minY,
          width: searchContainer.frame.width - 48,
          height: searchContainer.frame.height)
        userpicImageView.frame = CGRect(
          x: userpicImageView.frame.minX - 48,
          y: userpicImageView.frame.minY,
          width: userpicImageView.frame.width,
          height: userpicImageView.frame.height)
      }
      UIView.commitAnimations()
    }
    searchFor(text: sender.text)
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
