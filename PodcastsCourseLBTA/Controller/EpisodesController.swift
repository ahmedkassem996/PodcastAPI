//
//  EpisodesController.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 4/31/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController{
  
  var podcast: Podcast?{
    didSet{
      navigationItem.title = podcast?.trackName
      
      fetchEpisodes()
    }
  }
  
  fileprivate func fetchEpisodes(){
    guard let feedUrl = podcast?.feedUrl else { return }
    APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
      self.episodes = episodes
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
      }
  
  fileprivate let cellId = "cellId"
  
  var episodes = [Episode]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupNavigationBarButton()
  }
  
  //MARK:- SetupWork
  
  fileprivate func setupTableView(){
    let nib = UINib(nibName: "EpisodeCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
    tableView.tableFooterView = UIView()
  }
  
  //MARK:- UITableView
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let downloadaction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
      print("Downloading episode into user Defaults")
      let episode = self.episodes[indexPath.row]
      UserDefaults.standard.downloadEpisode(episode: episode)
      
      self.showDownloadBadgeHighlight()
      
      APIService.shared.downloadEpisode(episode: episode)
     
    }
    return[downloadaction]
  }
  
  fileprivate func setupNavigationBarButton(){
    let savedPodcasts = UserDefaults.standard.savedPodcasts()
    let hasFavourited = savedPodcasts.index(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName }) != nil
    if hasFavourited{
      navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: nil, action: nil)
    }else{
      navigationItem.rightBarButtonItems = [
        UIBarButtonItem(title: "Favourite", style: .plain, target: self, action: #selector(handleSaveFavourite)),
//        UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcast))
      ]
    }  
  }
  
  @objc fileprivate func handleFetchSavedPodcast(){
    print("fetch")
    guard let data = UserDefaults.standard.data(forKey: UserDefaults.favouritedPodcastKey) else{return}
    
    let savedPodcast = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]
    
    savedPodcast?.forEach({ (p) in
      print(p.trackName ?? "")
    })
  }
  
  @objc fileprivate func handleSaveFavourite(){
    print("favourite")
    
    guard let podcast = self.podcast else{ return}
    
    // transform podcast into data
    var listOfPodcasts = UserDefaults.standard.savedPodcasts()
    listOfPodcasts.append(podcast)
    
    let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
    
    UserDefaults.standard.set(data, forKey: UserDefaults.favouritedPodcastKey)
    
    showFavouriteBadgeHighlight()
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: nil, action: nil)
  }
  
  fileprivate func showDownloadBadgeHighlight(){
    UIApplication.mainTapBarController()?.viewControllers?[2].tabBarItem.badgeValue = "New"
  }
  
  fileprivate func showFavouriteBadgeHighlight(){
    UIApplication.mainTapBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    activityIndicatorView.color = .darkGray
    activityIndicatorView.startAnimating()
    return activityIndicatorView
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return episodes.isEmpty ? 200 : 0
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let episode = self.episodes[indexPath.row]
    let mainTapBarController = UIApplication.shared.keyWindow? .rootViewController as? MainTabBarController
    mainTapBarController?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
    
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episodes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
    let episode = episodes[indexPath.row]
    cell.episode = episode
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 134
  }
}
