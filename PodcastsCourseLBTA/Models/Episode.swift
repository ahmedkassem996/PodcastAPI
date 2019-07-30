//
//  Episode.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 4/31/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import Foundation
import FeedKit

struct Episode: Codable {
  let title: String
  let pubDate: Date
  let description: String
  let author: String
  var imageUrl: String?
  let streemUrl: String
  var fileUrl: String?
  
  init(feedItem: RSSFeedItem) {
    self.streemUrl = feedItem.enclosure?.attributes?.url ?? ""
    self.title = feedItem.title ?? ""
    self.pubDate = feedItem.pubDate ?? Date()
    self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
    self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    self.author = feedItem.iTunes?.iTunesAuthor ?? ""
    
  }
}
