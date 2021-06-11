//
//  Delegate.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 6/5/21.
//

import Foundation
protocol TabBarSwitchDelegate: AnyObject {
    // delegate protocol for when I am at a view controller and I want to switch to a different tab controller. Used when user is on someone's profile and taps message from there.
    func switchTab(_ tabNumber: Int, _ sender: Sender, _ channel: Channel)
}
