//
//  PodcastsSearchController.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 4/30/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController, UISearchBarDelegate{
  
  var podcasts = [Podcast]()
  
  let cellId = "cellId"
  
  // implement a UISearchController
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupSearchBar()
    setupTableView()
    
    searchBar(searchController.searchBar, textDidChange: "Npr")
  }
  
  //MARK:- Setup Work
  
  fileprivate func setupSearchBar(){
    self.definesPresentationContext = true
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
  }
  
  var timer: Timer?
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
      APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts) in
        self.podcasts = podcasts
        self.tableView.reloadData()
      }
   })
  }
  
  fileprivate func setupTableView(){
    tableView.tableFooterView = UIView()
    let nib = UINib(nibName: "Podcastcell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
  }
  
  //MARK:- UITableView
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let episodesController = EpisodesController()
    let podcast = self.podcasts[indexPath.row]
    episodesController.podcast = podcast
    navigationController?.pushViewController(episodesController, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel()
    label.text = "Please enter a Search Term"
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    label.textColor = .purple
    return label
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return self.podcasts.count > 0 ? 0 : 250
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return podcasts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
    let podcast = self.podcasts[indexPath.row]
    cell.podcast = podcast
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 132
  }
}
