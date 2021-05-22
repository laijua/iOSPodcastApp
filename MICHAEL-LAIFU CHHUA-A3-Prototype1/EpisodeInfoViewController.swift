//
//  EpisodeInfoViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit

class EpisodeInfoViewController: UIViewController {
    
    var episode: EpisodeData?
    
    
    
    @IBAction func podcastClick(_ sender: Any) {
    }
    
    @IBOutlet weak var podcastName: UIButton!
    @IBOutlet weak var episodeName: UILabel!
    @IBOutlet weak var episodeDate: UILabel!
    @IBOutlet weak var episodeLength: UILabel!
    @IBOutlet weak var episodeDescription: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let episode = episode{
            podcastName.setTitle(episode.podcastName, for: .normal)
            episodeName.text = episode.title
            episodeDate.text = episode.episodeDate
            episodeLength.text = episode.episodeLength
            episodeDescription.text = episode.episodeDescription
            
            
        }
        
    }
    
    @IBAction func toForum(_ sender: Any) {
        performSegue(withIdentifier: "forumSegue", sender: nil)
    }
    
    
    
    
     // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playerSegue"{
            let destination = segue.destination as! PlayerViewController
            destination.result = episode
        }
        
        if segue.identifier == "podcastSegue"{
            let destination = segue.destination as! PodcastInfoViewController
            destination.podcastID = episode?.podcastID
        }
        
        if segue.identifier == "forumSegue"{
            let destination = segue.destination as! ForumViewController
            destination.episode = episode
            
        }
     }
     
    
}
