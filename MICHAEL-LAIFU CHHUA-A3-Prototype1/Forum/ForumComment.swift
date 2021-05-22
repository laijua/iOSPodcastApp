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
    
    var parent: String?
    
//    var replies =  [ChildComment]()
    
    
//    var indentLevel: Int
    
    init(sender: Sender, messageId: String, sentDate: Date, message:String){
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.message = message
        // [1, [replies to 1 (indented)], 2]
    }
}

class ChildComment: NSObject{
    var sender: Sender
    
    var messageId: String
    
    var sentDate: Date
    
    var message: String
    
    init(sender: Sender, messageId: String, sentDate: Date, message:String){
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.message = message
    }
}

//section: [ParentComment]


//struct ParentComment {
//
//    var sender: Sender
//
//    var messageId: String
//
//    var sentDate: Date
//
//    var message: String
//
//    var childComments: [ChildComment]?
//}
//
//
//struct ChildComment {
//
//    var sender: Sender
//
//    var messageId: String
//
//    var sentDate: Date
//
//    var message: String
//}
