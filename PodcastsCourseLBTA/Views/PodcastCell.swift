//
//  PodcastCell.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 4/30/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell{
  
  @IBOutlet weak var podcastImageView: UIImageView!
  @IBOutlet weak var trackNameLbl: UILabel!
  @IBOutlet weak var artistNameLbl: UILabel!
  @IBOutlet weak var episodeCountLbl: UILabel!
  
  var podcast: Podcast!{
    didSet{
      trackNameLbl.text = podcast.trackName
      artistNameLbl.text = podcast.artistName
      
      episodeCountLbl.text = "\(podcast.trackCount ?? 0) Episodes"
      
      print("loading image", podcast.artworkUrl600 ?? "")
      
      guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
//      URLSession.shared.dataTask(with: url) { (data, _, _) in
//        print("Finished downloading image Data", data)
//        guard let data = data else { return }
//        DispatchQueue.main.async {
//          self.podcastImageView.image = UIImage(data: data)
//        }
//      }.resume()
      
      podcastImageView.sd_setImage(with: url, completed: nil)
    }
  }
}
