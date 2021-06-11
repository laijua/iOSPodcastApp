//
//  ForumTableViewCell.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 10/5/21.
//

import UIKit

class ForumTableViewCell: UITableViewCell {

    
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    @IBOutlet weak var replyUIButton: UIButton!
    var replyBlock: (() -> Void)? = nil
    
    @IBAction func reply(_ sender: Any) {
        replyBlock?()
    }
    
    var usernameBlock: (() -> Void)? = nil
    @IBAction func usernametapped(_ sender: Any) {
        usernameBlock?()
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
