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
    case podcasts2 = "recommendations"
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        
       
        podcasts = try? container.decode([PodcastData].self, forKey: .podcasts)
        if podcasts == nil{
            podcasts = try? container.decode([PodcastData].self, forKey: .podcasts2)
        }
        
     
    }
}
