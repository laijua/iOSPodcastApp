//
//  SearchResultData.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 1/5/21.
//

import UIKit

class SearchResultData: NSObject, Decodable {
    
    var results : [PodcastData]?

    private enum CodingKeys: String, CodingKey {
    case results
    }
}
