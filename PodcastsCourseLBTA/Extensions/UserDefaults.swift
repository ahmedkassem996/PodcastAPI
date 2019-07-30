//
//  UserDefaults.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 5/6/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import Foundation

extension UserDefaults{
  
  static let favouritedPodcastKey = "favouritedPodcastKey"
  static let downloadedEpisodeKey = "downloadedEpisodeKey"
  
  func downloadEpisode(episode: Episode){
    do{
      var episodes = downloadedEpisode()
      episodes.append(episode)
      let data = try JSONEncoder().encode(episodes)
      UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
    }catch let encodeErr{
      print("Failed to encode:", encodeErr)
    }
  }
  
  func downloadedEpisode() -> [Episode]{
    guard let episodesData = data(forKey: UserDefaults.downloadedEpisodeKey) else{return[]}
    
    do{
      let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
      return episodes
    }catch let decodeErr{
      print("Failed to decode:", decodeErr)
    }
    return []
  }
  
  func savedPodcasts() -> [Podcast]{
    guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favouritedPodcastKey) else { return []}
    guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastsData) as? [Podcast] else { return []}
    return savedPodcasts
  }
  
  func deletePodcast(podcast: Podcast){
    let podcasts = savedPodcasts()
    let filteredPodcasts = podcasts.filter { (p) -> Bool in
      return p.trackName != podcast.trackName && p.artistName != podcast.artistName
    }
    let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts)
    UserDefaults.standard.set(data, forKey: UserDefaults.favouritedPodcastKey)
  }
}
