//
//  EpisodeInfoViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit

class EpisodeInfoViewController: UIViewController {
    
    var episode: EpisodeData?
    var hidePodcastName = false
    
    @IBOutlet weak var podcastName: UIButton!
    @IBOutlet weak var episodeName: UILabel!
    @IBOutlet weak var episodeDate: UILabel!
    @IBOutlet weak var episodeLength: UILabel!
    @IBOutlet weak var episodeDescription: UITextView!
    @IBOutlet weak var episodeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        episodeButton.layer.cornerRadius = 15
        
        if hidePodcastName{
            podcastName.isHidden = true
            podcastName.isEnabled = false
        }
        
        if let episode = episode{
            podcastName.setTitle(episode.podcastName, for: .normal)
            episodeName.text = episode.title
            episodeDate.text = episode.episodeDate
            episodeLength.text = episode.episodeLength
            guard let episodeDesc = episode.episodeDescription else{return}
            episodeDescription.text = episodeDesc.html2String
            
            
        }
        
    }
    
    @IBAction func toForum(_ sender: Any) {
        performSegue(withIdentifier: "forumSegue", sender: nil)
    }
    
    @IBAction func queueButton(_ sender: Any) {
        if let episode = episode{
            playlistButtonInitialisation(episode)()
        }
        
    }
    
    
    
    
     // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playerSegue"{
            let destination = segue.destination as! PlayerViewController
            destination.episode = episode
            destination.playedFromQueue = false
        }
        
        if segue.identifier == "podcastSegue"{
            let destination = segue.destination as! PodcastInfoViewController
            destination.podcastID = episode?.podcastID
        }
        
        if segue.identifier == "forumSegue"{
            let destination = segue.destination as! ForumViewController
            destination.episode = episode
            destination.hidePodcastName = self.hidePodcastName
            
        }
     }
     
    
}
