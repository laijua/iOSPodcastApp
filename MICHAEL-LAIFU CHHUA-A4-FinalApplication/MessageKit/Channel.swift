//
//  Channel.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 2/5/21.
//

import UIKit

class Channel: NSObject {

    let id: String
    let name:String
    let senders: [String]
    // sender is of the format [a,b] or [b,a] depending on who messaged firs.  a and b are users. reason for this format is to filter out chat channels that dont include these 2 users.
    
    
    init(id: String, name:String, senders:[String]){
        self.id = id
        self.name = name
        self.senders = senders
    }
    
}
