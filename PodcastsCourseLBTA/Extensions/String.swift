//
//  String.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 4/31/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import Foundation


extension String{
  func toSecureHttps() -> String{
    return self.contains("https") ? self :
      self.replacingOccurrences(of: "http", with: "https")
  }
}
