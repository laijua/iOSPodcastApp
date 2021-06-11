//
//  EmptyEpisodesTableViewCell.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 6/9/21.
//

import UIKit

class EmptyEpisodesTableViewCell: UITableViewCell {

    @IBOutlet weak var searchUIButton: UIButton!
    @IBOutlet weak var noEpisodesText: UILabel!
    
    var searchBlock: (() -> Void)? = nil
    @IBAction func searchTapped(_ sender: Any) {
        searchBlock?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
