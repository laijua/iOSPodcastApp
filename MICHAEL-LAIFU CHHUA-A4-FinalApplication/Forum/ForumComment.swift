//
//  ForumComment.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 15/5/21.
//

import UIKit
// ChatMessage equivalent
class ForumComment: NSObject {
    var sender: Sender
    
    var messageId: String
    
    var sentDate: Date
    
    var message: String
    
    var parent: String? // if comment is a reply, it will have its parent's id
    

    
    init(sender: Sender, messageId: String, sentDate: Date, message:String){
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.message = message
        
    }
}


