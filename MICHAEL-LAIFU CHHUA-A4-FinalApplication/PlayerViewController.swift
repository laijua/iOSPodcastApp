//
//  PlayerViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    private let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
    var playedFromQueue = true // check if playing just an episode from episodeinfoviewcontroller or played from queue
    var episode: EpisodeData?
    
    private var playing = false
    private var audioPlayer: AVPlayer?
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var positionSlider: UISlider!
    @IBOutlet weak var episodeImage: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var playUIButton: UIButton!
    private var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        https://stackoverflow.com/questions/29386531/how-to-detect-when-avplayer-video-ends-playing/52747450
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
        ])
        indicator.color = UIColor(named: "Teal")
        setAudio()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        https://stackoverflow.com/questions/28733936/change-color-of-back-button-in-navigation-bar
        self.navigationController?.navigationBar.tintColor = UIColor(named: "Teal")
        
        //        https://stackoverflow.com/questions/31583648/hide-navigation-bar-but-keep-the-bar-button/31583908
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        view.backgroundColor = UIColor(named: "playerBackgroundColor")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        playing = false
        audioPlayer?.pause()
        let image = UIImage(systemName: "play.circle")
        self.playUIButton.setImage(image, for: .normal)
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.label
        navigationController?.navigationBar.barTintColor = UIColor(named: "Teal")
        self.navigationController?.navigationBar.isTranslucent = false
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func playButton(_ sender: Any) {
        if playing{
            playing = false
            audioPlayer?.pause()
            let image = UIImage(systemName: "play.circle")
            self.playUIButton.setImage(image, for: .normal)
        }
        else{
            playing = true
            audioPlayer?.play()
            let image = UIImage(systemName: "pause.circle")
            self.playUIButton.setImage(image, for: .normal)
            
        }
        
    }
    
    @IBAction func next(_ sender: Any) {
        
        if let audioPlayer = self.audioPlayer, let currentItem = audioPlayer.currentItem{
            let newTime = CMTime(seconds: Double(currentItem.duration.seconds), preferredTimescale: 1)
            audioPlayer.seek(to: newTime)
            self.positionSlider.value = Float(audioPlayer.currentTime().seconds)
        }
    }
    
    @IBAction func previous(_ sender: Any) {
        
        if let audioPlayer = self.audioPlayer{
            let currentTime = Float(audioPlayer.currentTime().seconds)
            if currentTime < 4 && appDelegate?.previousAudio.count ?? 0 > 0{
                // skip to previous
                
                if !playedFromQueue{
                    navigationController?.popViewController(animated: true)
                    return
                }

                guard let previousNowPlaying = appDelegate?.nowPlaying.removeFirst() else{return}
                appDelegate?.queueArray.insert(previousNowPlaying, at: 0)
                
                guard let newNowPlaying = appDelegate?.previousAudio.removeFirst() else {return}
                appDelegate?.nowPlaying.append(newNowPlaying)
                
                let queueData = NSKeyedArchiver.archivedData(withRootObject: appDelegate?.queueArray)
                UserDefaults.standard.set(queueData, forKey: "queue")
                
                let nowPlayingData = NSKeyedArchiver.archivedData(withRootObject: appDelegate?.nowPlaying)
                UserDefaults.standard.set(nowPlayingData, forKey: "nowPlaying")
                
                let previousData = NSKeyedArchiver.archivedData(withRootObject: appDelegate?.previousAudio)
                UserDefaults.standard.set(previousData, forKey: "previous")
                
                
                episode = appDelegate?.nowPlaying.first
                setAudio()
                
            }
            else{
                if let audioPlayer = self.audioPlayer{
                    let newTime = CMTime(seconds: Double(0), preferredTimescale: 1)
                    audioPlayer.seek(to: newTime)
                    self.positionSlider.value = Float(audioPlayer.currentTime().seconds)
                }
            }
        }
    }
    
    
    @IBAction func forward10(_ sender: Any) {
        if let audioPlayer = self.audioPlayer{
            let currentTime = Float(audioPlayer.currentTime().seconds)
            let newTime = CMTime(seconds: Double(currentTime+10), preferredTimescale: 1)
            audioPlayer.seek(to: newTime)
            self.positionSlider.value = Float(audioPlayer.currentTime().seconds)
        }
    }
    
    @IBAction func backward10(_ sender: Any) {
        if let audioPlayer = self.audioPlayer {
            let currentTime = Float(audioPlayer.currentTime().seconds)
            let newTime = CMTime(seconds: Double(currentTime-10), preferredTimescale: 1)
            audioPlayer.seek(to: newTime)
            self.positionSlider.value = Float(audioPlayer.currentTime().seconds)
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {

        if !playedFromQueue{
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard let toBePrevious = appDelegate?.nowPlaying.first else{return}
        appDelegate?.previousAudio = [toBePrevious]
        
        let previousData = NSKeyedArchiver.archivedData(withRootObject: appDelegate?.previousAudio)
        UserDefaults.standard.set(previousData, forKey: "previous")
        
        if appDelegate?.queueArray.count ?? 0 > 0 {
            episode = appDelegate?.queueArray.removeFirst()
            
            if let episode = episode{
                appDelegate?.nowPlaying = [episode]
            }
            
            let queueData = NSKeyedArchiver.archivedData(withRootObject: appDelegate?.queueArray)
            UserDefaults.standard.set(queueData, forKey: "queue")

            setAudio()
        }
        else{
            appDelegate?.nowPlaying = []
            navigationController?.popViewController(animated: true)
        }
        
        let nowPlayingData = NSKeyedArchiver.archivedData(withRootObject: appDelegate?.nowPlaying)
        UserDefaults.standard.set(nowPlayingData, forKey: "nowPlaying")
        
    }
    
    private func setAudio(){
        //        https://stackoverflow.com/questions/29068243/swift-how-to-disable-user-interaction-while-touch-action-is-being-carried-out
        view.isUserInteractionEnabled = false
        indicator.startAnimating()
        positionSlider.value = 0
        self.endTimeLabel.text = ""
        self.currentTimeLabel.text = ""

        if let result = episode, let string = result.audio,let image = result.image, let imageURL = URL(string: image), let url = URL(string: string), let title = result.title{
            audioPlayer = AVPlayer(url: url)
            
            
            // Update the slider positon 4 times a second.
            audioPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 4), queue: DispatchQueue.main, using: { (time) in
                
                if let audioPlayer = self.audioPlayer, let currentItem = audioPlayer.currentItem {
                    
                    let duration = Double(currentItem.duration.seconds)
                    if duration.isNaN{
                        self.endTimeLabel.text = ""
                        self.currentTimeLabel.text = ""
                    }
                    else{
                        var (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: Int(duration))
                        var stringM = "\(m)"
                        if stringM.count < 2{
                            stringM = "0\(m)"
                        }
                        
                        var stringS = "\(s)"
                        if stringS.count < 2{
                            stringS = "0\(s)"
                        }
                        
                        self.endTimeLabel.text = "\(h)h \(stringM)m \(stringS)s"
                        
                        
                        let current = Double(audioPlayer.currentTime().seconds)
                        (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: Int(current))
                        stringM = "\(m)"
                        if stringM.count < 2{
                            stringM = "0\(m)"
                        }
                        
                        stringS = "\(s)"
                        if stringS.count < 2{
                            stringS = "0\(s)"
                        }
                        self.currentTimeLabel.text = "\(h)h \(stringM)m \(stringS)s"
                    }
                    
                    // https://stackoverflow.com/questions/56262177/error-when-setting-uisliders-min-and-max-values
                    if audioPlayer.currentItem?.status == .readyToPlay{
                        self.positionSlider.maximumValue = Float(currentItem.duration.seconds)
                        self.positionSlider.value = Float(audioPlayer.currentTime().seconds)
                        self.view.isUserInteractionEnabled = true
                        self.indicator.stopAnimating()
                        if self.playing{
                            let image = UIImage(systemName: "pause.circle")
                            self.playUIButton.setImage(image, for: .normal)
                        }
                    }
                    
                }
            })
            playing = true
            audioPlayer?.play()
            
            
            let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let _ = error{
                    return
                }
                if let data = data, let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self.episodeImage.image = image
                    }
                }
            }
            task.resume()
            
            episodeTitle.text = title
            
        }
    }
    
    
    @IBAction func positionChanged(_ sender: Any) {
        let newTime = CMTime(seconds: Double(positionSlider.value), preferredTimescale: 1)
        audioPlayer?.seek(to: newTime)
    }
    
    @IBAction func forumButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forumViewController = storyboard.instantiateViewController(identifier: "ForumViewController") as! ForumViewController
        forumViewController.episode = episode
        forumViewController.hidePodcastName = true
        self.navigationController?.pushViewController(forumViewController, animated: true)
    }
}
