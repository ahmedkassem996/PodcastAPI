//
//  RSSFeed.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 4/31/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import FeedKit

extension RSSFeed{
  func toEpisodes() -> [Episode]{
    
    let imageUrl = iTunes?.iTunesImage?.attributes?.href
    
    var episodes = [Episode]()
    
    items?.forEach({ (feedItem) in
      var episode = Episode(feedItem: feedItem)
      
      
      if episode.imageUrl == nil{
        episode.imageUrl = imageUrl
      }
      
      episodes.append(episode)
    })
    return episodes
  }
}
