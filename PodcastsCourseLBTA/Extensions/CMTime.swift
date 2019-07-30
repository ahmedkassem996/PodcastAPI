//
//  CMTime.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 5/2/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import AVKit

extension CMTime{
  
  func toDisplayString() -> String{
    
    if CMTimeGetSeconds(self).isNaN{
      return "--:--"
    }
    
    let totalSeconds = Int(CMTimeGetSeconds(self))
    let seconds = totalSeconds % 60
    let minutes = totalSeconds / 60
    let timeFormatString = String(format: "%2d:%02d", minutes, seconds)
    return timeFormatString
  }
}
