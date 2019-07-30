//
//  APIService.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 4/30/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

extension NSNotification.Name{
  static let downloadProgress = NSNotification.Name("downloadProgress")
  static let downloadComplete = NSNotification.Name("downloadComplete")
}

class APIService{
  
  typealias EpisodedownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
  
  let baseItunesSearchURL = "https://itunes.apple.com/search"
  
  static let shared = APIService()
  
  func downloadEpisode(episode: Episode){
    print("Downloading episode using alamofire", episode.streemUrl)
    
    
    let downloadRequest = DownloadRequest.suggestedDownloadDestination()
    
    Alamofire.download(episode.streemUrl, to: downloadRequest).downloadProgress { (progress) in
   //   print(progress.fractionCompleted)
      
      NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
      
      
      }.response { (resp) in
        print(resp.destinationURL?.absoluteString ?? "")
        
        let episodeDownloadComplete = EpisodedownloadCompleteTuple(resp.destinationURL?.absoluteString ?? "", episode.title)
        NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
        
        var downloadEpisodes = UserDefaults.standard.downloadedEpisode()
        guard let index = downloadEpisodes.index(where: {
          $0.title == episode.title && $0.author == episode.author
        }) else { return }
        downloadEpisodes[index].fileUrl = resp.destinationURL?.absoluteString ?? ""
        
        do{
          let data = try JSONEncoder().encode(downloadEpisodes)
          UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
        }catch let err{
          print("failed to encode download:", err)
        }
    }
  }
  
  func fetchEpisodes(feedUrl: String, completionHandler: @escaping([Episode]) -> ()){
    let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")
    guard let url = URL(string: secureFeedUrl) else { return }
    
    DispatchQueue.global(qos: .background).async {
      let parser = FeedParser(URL: url)
      parser.parseAsync { (result) in
        print("Succfully parse feed:", result.isSuccess)
        
        if let err = result.error{
          print("Failed to parse XML feed:", err)
          return
        }
        
        guard let feed = result.rssFeed else { return }
        let episodes = feed.toEpisodes()
        completionHandler(episodes)
      }
    }
  }
  
  
  
  func fetchMusic(){
    baseItunesSearchURL
  }
  
  func fetchPodcasts(searchText: String, completionhandler: @escaping([Podcast]) -> ()){
    print("Searching for podcasts...")
    
    let parameters = ["term": searchText, "media": "podcast"]
    
    Alamofire.request(baseItunesSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
      
      if let err = dataResponse.error{
        print("Failed to contact yahoo", err)
        return
      }
      guard let data = dataResponse.data else { return }
      do{
        print("3")
        let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
        print(searchResult.resultCount)
        completionhandler(searchResult.results)
      }catch let decodeErr{
        print("Failed to decode:", decodeErr)
      }
    }
    print("2")
  }
  
  struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Podcast]
  }
}
