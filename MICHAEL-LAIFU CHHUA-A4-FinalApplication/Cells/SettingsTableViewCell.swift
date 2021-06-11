//
//  SettingsTableViewCell.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 10/5/21.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    var signOutBlock: (() -> Void)? = nil
    
    @IBAction func signOut(_ sender: Any) {
        signOutBlock?()
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
