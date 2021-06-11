//
//  Sender.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 2/5/21.
//

import UIKit
import MessageKit

class Sender: SenderType {
    var senderId: String // id of current user in firebase
    var displayName: String // display name of current user
    
    init(id: String, name:String){
        self.senderId = id
        self.displayName = name
    }
    
}
