//
//  UIApplication.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 5/4/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit

extension UIApplication{
  static func mainTapBarController() -> MainTabBarController?{
   //UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
    
    return shared.keyWindow?.rootViewController as? MainTabBarController
  }
}
