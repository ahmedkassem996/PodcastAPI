//
//  EpisodeCell.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 4/31/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
  
  var episode: Episode!{
    didSet{
      titleLbl.text = episode.title
      descriptionLbl.text = episode.description
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM dd, yyy"
      pubDateLbl.text = dateFormatter.string(from: episode.pubDate)
      
      let url = URL(string: episode.imageUrl?.toSecureHttps() ?? "")
      episodeImageView.sd_setImage(with: url)
    }
  }
  
  @IBOutlet weak var progressLbl: UILabel!
  @IBOutlet weak var episodeImageView: UIImageView!
  @IBOutlet weak var pubDateLbl: UILabel!
  @IBOutlet weak var titleLbl: UILabel!{
    didSet{
      titleLbl.numberOfLines = 2
    }
  }
  @IBOutlet weak var descriptionLbl: UILabel!{
    didSet{
      descriptionLbl.numberOfLines = 2
    }
  }
  
}
