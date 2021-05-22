//
//  PodcastData.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 1/5/21.
//

import UIKit

class PodcastData: NSObject, Decodable {
    var title: String?
    var image: String?
    var episodes: [EpisodeData]?
    var podcastDescription: String?
    var id: String?
    
    private enum CodingKeys:String, CodingKey{
        case title
        case title2 = "title_original"
        case image
        case episodes
        case podcastDescription = "description"
        case podcastDescription2 = "description_original"
        case id
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        
        title = try? container.decode(String.self, forKey: .title)
        if title == nil{
            title = try? container.decode(String.self, forKey: .title2)
        }
        
        
        image = try? container.decode(String.self, forKey: .image)
        
        episodes = try? container.decode([EpisodeData].self, forKey: .episodes)
        
        podcastDescription = try? container.decode(String.self, forKey: .podcastDescription)
        if podcastDescription == nil{
            podcastDescription = try? container.decode(String.self, forKey: .podcastDescription2)
        }
        
        id = try? container.decode(String.self, forKey: .id)
    }
}
