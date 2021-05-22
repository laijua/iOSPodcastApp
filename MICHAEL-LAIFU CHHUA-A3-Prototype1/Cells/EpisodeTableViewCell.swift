//
//  NewEpisodeTableViewCell.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit

class EpisodeTableViewCell: UITableViewCell {
    @IBOutlet weak var episodeImage: UIImageView!
    
    @IBOutlet weak var episodeTitle: UILabel!
    
   // @IBOutlet weak var episodeDescription: UILabel!
    @IBOutlet weak var dateOfUpload: UILabel!
    @IBOutlet weak var podcastName: UILabel!
    @IBOutlet weak var episodeLength: UILabel!
    //    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        return imageView
//    }()
    
    
    var forumBlock: (() -> Void)? = nil
    @IBAction func forumButton(_ sender: Any) {
        forumBlock?()
    }
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
