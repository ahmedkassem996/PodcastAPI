//
//  DownloadsController.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 5/7/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController{
  
  fileprivate let cellId = "cellId"
  
  var episodes = UserDefaults.standard.downloadedEpisode()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTableView()
    
    setupObserver()
  }
  
  fileprivate func setupObserver(){
    NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
  
  @objc fileprivate func handleDownloadComplete(notification: Notification){
    guard let episodeDownloadComplete = notification.object as? APIService.EpisodedownloadCompleteTuple else { return }
    
    guard let index = self.episodes.index(where: {
      $0.title == episodeDownloadComplete.episodeTitle
    }) else { return }
    
    self.episodes[index].fileUrl = episodeDownloadComplete.fileUrl
  }
  
  @objc fileprivate func handleDownloadProgress(notification: Notification){
    guard let userInfo = notification.userInfo as? [String: Any] else{ return }
    guard let progress = userInfo["progress"] as? Double else { return }
    guard let title = userInfo["title"] as? String else { return }
    
    print(progress, title)
    
    guard let index = self.episodes.index(where: {
      $0.title == title
    }) else { return }
    
    guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
    cell.progressLbl.text = "\(Int(progress * 100))%"
    cell.progressLbl.isHidden = false
    
    if progress == 1{
      cell.progressLbl.isHidden = true
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    episodes = UserDefaults.standard.downloadedEpisode()
    tableView.reloadData()
    UIApplication.mainTapBarController()?.viewControllers?[2].tabBarItem.badgeValue = nil
  }
  
  fileprivate func setupTableView(){
    let nib = UINib(nibName: "EpisodeCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
  }
  
  //MARK:- UITableView
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("launch episode player")
    
    let episode = self.episodes[indexPath.row]
    
    if episode.fileUrl != nil{
      UIApplication.mainTapBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
    }else{
      let alertController = UIAlertController(title: "File url not found", message: "cannot find local file, play using streem url intersting", preferredStyle: .actionSheet)
      
      alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
        UIApplication.mainTapBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
      }))
      
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
      
      present(alertController, animated: true)
    }
    
    
    
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episodes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
    cell.episode = self.episodes[indexPath.row]
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 134
  }
  
 
}
