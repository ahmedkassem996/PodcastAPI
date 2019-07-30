//
//  PlayerDetailsView.swift
//  PodcastsCourseLBTA
//
//  Created by AHMED on 5/1/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView{
  
  var episode: Episode!{
    didSet{
      miniTitleLbk.text = episode.title
      titleLbl.text = episode.title
      autherLbl.text = episode.author
      
      setupNowPlayingInfo()
      setupAudioSession()
      playEpisode()
      
      guard let url = URL(string: episode.imageUrl ?? "") else{return}
      episodeImageview.sd_setImage(with: url)
     // miniEpisiodImageView.sd_setImage(with: url)
      
      miniEpisiodImageView.sd_setImage(with: url) { (image, _, _, _) in
        
        guard let image = image else { return }
        
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
          return image
        })
        
        nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
      }
      
    }
  }
  
  fileprivate func setupNowPlayingInfo(){
    var nowPlayingInfo = [String: Any]()
    
    nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
    nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
    
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
  }
  
  fileprivate func playEpisode(){
    
    if episode.fileUrl != nil{
      playEpisodeUsingFileUrl()
    }else{
      print("trying to play episode at url:", episode.streemUrl)
      
      guard let url = URL(string: episode.streemUrl) else { return }
      let playerItem = AVPlayerItem(url: url)
      player.replaceCurrentItem(with: playerItem)
      player.play()
    }
    
    
  }
  
  fileprivate func playEpisodeUsingFileUrl(){
    print("Attempt to play episodes with fileUrl:", episode.fileUrl ?? "")
    
    guard let fileUrl = URL(string: episode.fileUrl ?? "") else{return}
    let fileName = fileUrl.lastPathComponent
    
    
    guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{return}
    
    trueLocation.appendPathComponent(fileName)
    print(trueLocation.absoluteString)
    
    let playerItem = AVPlayerItem(url: trueLocation)
    player.replaceCurrentItem(with: playerItem)
    player.play()
  }
  
  let player: AVPlayer = {
    let avPlayer = AVPlayer()
    avPlayer.automaticallyWaitsToMinimizeStalling = false
    return avPlayer
  }()
  
  fileprivate func opservePlayerCurrentTime(){
    let interval = CMTimeMake(value: 1, timescale: 2)
    player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
     
      self?.currentTimeLbl.text = time.toDisplayString()
      
      let durationtime = self?.player.currentItem?.duration
      self?.durationLbl.text = durationtime?.toDisplayString()
      
 //     self?.setupLockScreenCurrentTime()
      
      self?.updateCurrentTimeSlider()
    }
  }
  
//  fileprivate func setupLockScreenCurrentTime(){
//    var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
//
//    guard let currentItem = player.currentItem else{ return}
//    let durationInSeconds = CMTimeGetSeconds(currentItem.duration)
//
//    let elapsedTime = CMTimeGetSeconds(player.currentTime())
//
//    nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
//
//    nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
//    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//  }
  
  fileprivate func updateCurrentTimeSlider(){
    let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
    let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
    let persentage = currentTimeSeconds / durationSeconds
    
    self.currentTimeSlider.value = Float(persentage)
  
  }
  
  var panGesture: UIPanGestureRecognizer!
  
  fileprivate func setupGestures() {
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    addGestureRecognizer(panGesture)
    miniPlayerView.addGestureRecognizer(panGesture)
    
    maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
  }
  
  @objc func handleDismissalPan(gesture: UIPanGestureRecognizer){
    if gesture.state == .changed{
      let translation = gesture.translation(in: superview)
      maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
    }else if gesture.state == .ended{
      let translation = gesture.translation(in: superview)
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        self.maximizedStackView.transform = .identity
        
        if translation.y > 50{
          let mainTapBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
          mainTapBarController?.minimizePlayerDetails()
        }
        
      })
    }
  }
  
  fileprivate func setupAudioSession(){
    do{
      try
         AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
      
      try AVAudioSession.sharedInstance().setActive(true)
    }catch let sessionErr{
      print("Failed to activiate session", sessionErr)
    }
  }
  
  fileprivate func setupRemoteControl(){
    UIApplication.shared.beginReceivingRemoteControlEvents()
    
    let commandCenter = MPRemoteCommandCenter.shared()
    
    commandCenter.playCommand.isEnabled = true
    commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
      self.player.play()
      self.playPauseBtn.setImage(UIImage(named: "play"), for: .normal)
      self.miniPlayerPauseBtn.setImage(UIImage(named: "play"), for: .normal)
      
      self.setupElapsedTime(playBackRate: 1)
      return .success
    }
    
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
      self.player.pause()
      self.playPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
      self.miniPlayerPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
      self.setupElapsedTime(playBackRate: 0)
      return .success
    }
    
    commandCenter.togglePlayPauseCommand.isEnabled = true
    commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
      
      self.handlePlayPause()
      return .success
    }
    
    commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
    commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
  }
  
  var playlistEpisodes = [Episode]()
  
  @objc fileprivate func handlePreviousTrack(){
    
  }
  
  @objc fileprivate func handleNextTrack(){
    playlistEpisodes.forEach({print($0.title)})
    
    if playlistEpisodes.count == 0{
      return
    }
    
    let currentEpisodeIndex = playlistEpisodes.index{ (ep) -> Bool in
      return self.episode.title == ep.title &&
      self.episode.author == ep.author
    }
    
    guard let index = currentEpisodeIndex else { return }
    
    let nextEpisode: Episode
    if index == playlistEpisodes.count - 1{
      nextEpisode = playlistEpisodes[0]
    }else{
      nextEpisode = playlistEpisodes[index + 1]
    }
    self.episode = nextEpisode
  }
  
  fileprivate func setupElapsedTime(playBackRate: Float){
    let elapsedTime = CMTimeGetSeconds(player.currentTime())
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playBackRate
  }
  
  fileprivate func observeBondaryTime() {
    let time = CMTimeMake(value: 1,timescale: 3)
    let times = [NSValue(time: time)]
    player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
      print("Episode start playing")
      self?.enlargeEpisodeImageView()
      self?.setupLockScreen()
    }
  }
  
  fileprivate func setupLockScreen(){
    guard let duration = player.currentItem?.duration else { return }
    let durationSeconds = CMTimeGetSeconds(duration)
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
  }
  
  fileprivate func setupInterruptionObserver(){
    NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)

  }
  
  @objc fileprivate func handleInterruption(_ notification: Notification){
    guard let userInfo = notification.userInfo else{ return}
    guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else{ return}
    
    if type == AVAudioSession.InterruptionType.began.rawValue{
      print("interruption began")
      
      playPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
      miniPlayerPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
    }else{
      print("interruption ended")
      
      guard let options = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else{ return}
      
      if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue{
        player.play()
        playPauseBtn.setImage(UIImage(named: "play"), for: .normal)
        miniPlayerPauseBtn.setImage(UIImage(named: "play"), for: .normal)
      }
    }
    
    
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setupRemoteControl()
    
  //  setupAudioSession()
    
    setupGestures()
    
    opservePlayerCurrentTime()
    
    observeBondaryTime()
    
    setupInterruptionObserver()
  }
  
  @objc func handlePan(gesture: UIPanGestureRecognizer){
    if gesture.state == .changed{
      handlePanChanged(gesture: gesture)
    }else if gesture.state == .ended{
      handlePanEnded(gesture: gesture)
    }
  }
  
  func handlePanChanged(gesture: UIPanGestureRecognizer){
    let translation = gesture.translation(in: self.superview)
    self.transform = CGAffineTransform(translationX: 0, y: translation.y)
    
    self.miniPlayerView.alpha = 1 + translation.y / 200
    self.maximizedStackView.alpha = -translation.y / 200
  }
  
  func handlePanEnded(gesture: UIPanGestureRecognizer){
    let translation = gesture.translation(in: self.superview)
    let velocity = gesture.velocity(in: self.superview)
    print("ended", velocity.y)
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      
      self.transform = .identity
      
      if translation.y < -200 || velocity.y < -500{
        UIApplication.mainTapBarController()?.maximizePlayerDetails(episode: nil)
      }else{
        self.miniPlayerView.alpha = 1
        self.maximizedStackView.alpha = 0
      }
    })
  }
  
  @objc func handleTapMaximize(){
    UIApplication.mainTapBarController()?.maximizePlayerDetails(episode: nil)
  }
  
  static func initFromNip() -> PlayerDetailsView{
    return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
  }
  
  deinit {
    print("playerDetailsView memory being reclaimed")
  }
  
  //MARK:- IB Actions and Outlets
  
  @IBOutlet weak var miniEpisiodImageView: UIImageView!
  @IBOutlet weak var miniTitleLbk: UILabel!
  @IBOutlet weak var miniPlayerPauseBtn: UIButton!{
    didSet{
      miniPlayerPauseBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
    }
  }
  
  @IBOutlet weak var miniFastForwardBtn: UIButton!
  @IBOutlet weak var miniPlayerView: UIView!
  @IBOutlet weak var maximizedStackView: UIStackView!
  
  @IBAction func handleCurrentTimeSliderChange(_ sender: Any){
    let persentage = currentTimeSlider.value
    guard let duration = player.currentItem?.duration else{ return }
    let durationInSeconds = CMTimeGetSeconds(duration)
    let seekTimeInSeconds = Float64(persentage) * durationInSeconds
    let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
    
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
    
    player.seek(to: seekTime)
  }
  
  @IBAction func handleRewind(_ sender: Any){
    seekToCurrentTime(delta: -15)
  }
  
  @IBAction func handleFastForward(_ sender: Any){
    seekToCurrentTime(delta: 15)
  }
  
  fileprivate func seekToCurrentTime(delta: Int64){
    let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
    let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
    player.seek(to: seekTime)
  }
  
  @IBAction func handleVolumechange(_ sender: UISlider){
    player.volume = sender.value
  }
  
  @IBOutlet weak var currentTimeSlider: UISlider!
  @IBOutlet weak var durationLbl: UILabel!
  @IBOutlet weak var currentTimeLbl: UILabel!
  
  @IBOutlet weak var playPauseBtn: UIButton!{
    didSet{
      playPauseBtn.setImage(UIImage(named: "play"), for: .normal)
      playPauseBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
    }
  }
  
  @objc func handlePlayPause(){
    print("Trying to play and pause")
    if player.timeControlStatus == .paused{
      player.play()
      playPauseBtn.setImage(UIImage(named: "play"), for: .normal)
      miniPlayerPauseBtn.setImage(UIImage(named: "play"), for: .normal)
      enlargeEpisodeImageView()
      self.setupElapsedTime(playBackRate: 1)
    }else{
      player.pause()
      playPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
      miniPlayerPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
      shrinkEpisodeImageView()
      self.setupElapsedTime(playBackRate: 0)
    }
  }
  
  @IBOutlet weak var autherLbl: UILabel!
  @IBOutlet weak var episodeImageview: UIImageView!{
    didSet{
      episodeImageview.layer.cornerRadius = 5
      episodeImageview.clipsToBounds = true
      let scale: CGFloat = 0.7
      episodeImageview.transform = self.shurnnkentransform
    }
  }
  
  fileprivate func enlargeEpisodeImageView(){
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.episodeImageview.transform = .identity
    })
  }
  
  fileprivate let shurnnkentransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
  
  fileprivate func shrinkEpisodeImageView(){
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      let scale: CGFloat = 0.8
      self.episodeImageview.transform = self.shurnnkentransform
    })
  }
  
  @IBOutlet weak var titleLbl: UILabel!{
    didSet{
      titleLbl.numberOfLines = 2
    }
  }
  
  @IBAction func handleDismiss(_ sender: Any){
    let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
    mainTabBarController?.minimizePlayerDetails()
    
  }
  
}
