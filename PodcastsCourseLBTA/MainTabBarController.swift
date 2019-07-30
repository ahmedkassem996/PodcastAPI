//
//  MainTabBarController.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 4/29/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UINavigationBar.appearance().prefersLargeTitles = true
    
    tabBar.tintColor = .purple
    
    setupViewController()
    
    setupPlayerDetailsView()
  }
  
  @objc func minimizePlayerDetails(){
    maximizedtopAnchorConstraint.isActive = false
    bottomAnchorConstraint.constant = view.frame.height
    minimizedtopAnchorConstraint.isActive = true

    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      
      self.view.layoutIfNeeded()
      
      self.tabBar.transform = .identity
      
      self.playerDetailsView.maximizedStackView.alpha = 0
      self.playerDetailsView.miniPlayerView.alpha = 1
      
    })
  }
  
  func maximizePlayerDetails(episode: Episode?, playlistEpisodes: [Episode] = []){
    maximizedtopAnchorConstraint.isActive = true
    maximizedtopAnchorConstraint.constant = 0
    minimizedtopAnchorConstraint.isActive = false
    
    bottomAnchorConstraint.constant = 0
    
    if episode != nil{
      playerDetailsView.episode = episode
    }
    
    playerDetailsView.playlistEpisodes = playlistEpisodes
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      
      self.view.layoutIfNeeded()
      
      self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
      
      self.playerDetailsView.maximizedStackView.alpha = 1
      self.playerDetailsView.miniPlayerView.alpha = 0
      
    })
  }
  
  //MARK:- Setup Functions
  
  let playerDetailsView = PlayerDetailsView.initFromNip()
  var maximizedtopAnchorConstraint: NSLayoutConstraint!
  var minimizedtopAnchorConstraint: NSLayoutConstraint!
  var bottomAnchorConstraint: NSLayoutConstraint!
  
  func setupPlayerDetailsView(){
    print("setting up playerDetailsView")
    
    view.insertSubview(playerDetailsView, belowSubview: tabBar)
    
    playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
    
    //view.addSubview(playerDetailsView)
    
    maximizedtopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
    maximizedtopAnchorConstraint.isActive = true
    
    bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
    bottomAnchorConstraint.isActive = true
    
    minimizedtopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
    //minimizedtopAnchorConstraint.isActive = true
    
    playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
  }
  
  func setupViewController(){
    
    let layout = UICollectionViewFlowLayout()
    let favouritesController = FavouritesController(collectionViewLayout: layout)
    viewControllers = [
      generateNavigationController(for: PodcastsSearchController(), title: "Search", image: UIImage(named: "Search")!),
      generateNavigationController(for: favouritesController, title: "Favorites", image: UIImage(named: "Favorites")!),
      generateNavigationController(for: DownloadsController(), title: "Downloads", image: UIImage(named: "Downloads")!)
    ]
  }
  
  //MARK:- Helper Functions
  
  fileprivate func generateNavigationController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController{
    let navController = UINavigationController(rootViewController: rootViewController)
//    navController.navigationBar.prefersLargeTitles = true
    rootViewController.navigationItem.title = title
    navController.tabBarItem.title = title
    navController.tabBarItem.image = image
    return navController
  }
}
