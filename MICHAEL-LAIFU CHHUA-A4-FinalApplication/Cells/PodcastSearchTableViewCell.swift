//
//  PodcastSearchTableViewCell.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 24/5/21.
//

import UIKit

class PodcastSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var podcastImage: UIImageView!
    
    @IBOutlet weak var podcastName: UILabel!
    @IBOutlet weak var podcastDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
