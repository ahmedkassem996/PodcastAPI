//
//  Podcast.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 4/30/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import Foundation


class Podcast: NSObject, Decodable, NSCoding {
  func encode(with aCoder: NSCoder) {
    print("trying to transform podcast into data")
    aCoder.encode(trackName ?? "", forKey: "trackNameKey")
    aCoder.encode(artistName ?? "", forKey: "artistNameKey")
    aCoder.encode(artworkUrl600 ?? "", forKey: "artWorkKey")
    aCoder.encode(feedUrl ?? "", forKey: "feedKey")
  }
  
  required init?(coder aDecoder: NSCoder) {
    print("Trying to turn data into podcast")
    self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
    self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
    self.artworkUrl600 = aDecoder.decodeObject(forKey: "artWorkKey") as? String
    self.feedUrl = aDecoder.decodeObject(forKey: "feedKey") as? String
  }
  
  var trackName: String?
  var artistName: String?
  var artworkUrl600: String?
  var trackCount: Int?
  var feedUrl: String?
}
