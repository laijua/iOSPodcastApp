//
//  CommentHeader.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 18/5/21.
//

import UIKit

final class CommentHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var collapse: UIButton!
    
    
    
    // https://stackoverflow.com/questions/30105189/how-to-add-a-button-with-click-event-on-uitableviewcell-in-swift
    var actionBlock: (() -> Void)? = nil
    
    @IBAction func reply(_ sender: Any) {
        actionBlock?()
        print("the button in the header works")
    }
    
    var collapseBlock: (() -> Void)? = nil
    
    @IBAction func collapse(_ sender: Any) {
        collapseBlock?()
    }
    
}
