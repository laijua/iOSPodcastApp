//
//  ListOfPodcastData.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 8/5/21.
//

import UIKit

class ListOfPodcastData: NSObject, Decodable {
    
    var podcasts : [PodcastData]?

    private enum CodingKeys: String, CodingKey {
    case podcasts
    }
}
