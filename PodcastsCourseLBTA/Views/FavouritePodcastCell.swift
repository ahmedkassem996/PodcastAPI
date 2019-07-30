//
//  FavouritePodcastCell.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 5/5/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit

class FavouritePodcastCell: UICollectionViewCell {
  
  var podcast: Podcast!{
    didSet{
      nameLbl.text = podcast.trackName
      artistNameLbl.text = podcast.artistName
      
      let url = URL(string: podcast.artworkUrl600 ?? "")
      imageView.sd_setImage(with: url)
    }
  }
  
  let imageView = UIImageView(image: UIImage(named: "artistImage"))
  let nameLbl = UILabel()
  let artistNameLbl = UILabel()
  
  fileprivate func styleizeUI() {
    nameLbl.text = "Podcast Name"
    nameLbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    artistNameLbl.text = "Artist Name"
    artistNameLbl.font = UIFont.systemFont(ofSize: 14)
    artistNameLbl.textColor = .lightGray
  }
  
  fileprivate func setupViews() {
    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    
    let stackView = UIStackView(arrangedSubviews: [imageView, nameLbl, artistNameLbl])
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)
    
    stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    styleizeUI()
    
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
