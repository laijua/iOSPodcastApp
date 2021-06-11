//
//  CommentHeader.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 18/5/21.
//

import UIKit

final class CommentHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var collapse: UIButton!
    @IBOutlet weak var username: UIButton!
    
    @IBOutlet weak var replyUIButton: UIButton!
    
    @IBOutlet weak var collapseUIButton: UIButton!
    
    // https://stackoverflow.com/questions/30105189/how-to-add-a-button-with-click-event-on-uitableviewcell-in-swift
    var replyBlock: (() -> Void)? = nil
    
    @IBAction func reply(_ sender: Any) {
        replyBlock?()
    }
    
    var collapseBlock: (() -> Void)? = nil
    
    @IBAction func collapse(_ sender: Any) {
        collapseBlock?()
    }
    
    
    var usernameBlock: (() -> Void)? = nil
    @IBAction func usernameAction(_ sender: Any) {
        usernameBlock?()
    }
}
