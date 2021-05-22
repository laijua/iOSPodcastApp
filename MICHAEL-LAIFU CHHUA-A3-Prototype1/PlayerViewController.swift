//
//  PlayerViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    @IBAction func playButton(_ sender: Any) {
        if playing{
            playing = false
            audioPlayer?.pause()
        }
        else{
            playing = true
            audioPlayer?.rate = 2
            audioPlayer?.play()
//            audioPlayer?.playImmediately(atRate: 2)
        }
        
    }
    @IBAction func speedUp(_ sender: Any) {
        audioPlayer?.playImmediately(atRate: 2)
    }
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var positionSlider: UISlider!
    @IBOutlet weak var episodeImage: UIImageView!
    
    
    var result: EpisodeData?
    
    var playing = false
    
    
    var audioPlayer: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        https://stackoverflow.com/questions/31583648/hide-navigation-bar-but-keep-the-bar-button/31583908
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        view.backgroundColor = UIColor(named: "playerBackgroundColor")
        
        positionSlider.value = 0
        
        if let result = result, let string = result.audio,let image = result.image, let imageURL = URL(string: image), let url = URL(string: string), let title = result.title{
            audioPlayer = AVPlayer(url: url)
            
            
            // Update the slider positon 4 times a second.
            audioPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 4), queue: DispatchQueue.main, using: { (time) in
                
                if let audioPlayer = self.audioPlayer, let currentItem = audioPlayer.currentItem {
                    self.positionSlider.maximumValue = Float(currentItem.duration.seconds)
                    self.positionSlider.value = Float(audioPlayer.currentTime().seconds)
                }
            })
            
            let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let error = error{
                    print(error)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        audioPlayer?.pause()
        navigationController?.navigationBar.barTintColor = UIColor(named: "Teal")
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    @IBAction func positionChanged(_ sender: Any) {
        let newTime = CMTime(seconds: Double(positionSlider.value), preferredTimescale: 1)
        audioPlayer?.seek(to: newTime)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
