//
//  Result.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 1/5/21.
//

import UIKit

class EpisodeData: NSObject, Decodable {
    var audio: String?
    var image: String?
    var title: String?
    var episodeLength: String?
    var episodeDescription: String?
    var episodeDate: String?
    var podcastName: String?
    var podcastID: String?
    var ms: Int?
    
    private enum CodingKeys:String, CodingKey{
        case audio
        case image
        case title = "title_original"
        case title2 = "title"
        case episodeLength = "audio_length_sec"
        case episodeDescription = "description_original"
        case episodeDescription2 = "description"
        case episodeDate = "pub_date_ms"
        case podcast
    }
    
    private struct Podcast: Decodable{
        var title:String
        var id: String
        
        
    }
    private enum PodcastKeys: String, CodingKey{
        case title = "title_original"
        case id
    }
    

    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        audio = try? container.decode(String.self, forKey: .audio)
        image = try? container.decode(String.self, forKey: .image)
        title = try? container.decode(String.self, forKey: .title)
        if title == nil{
            title = try? container.decode(String.self, forKey: .title2)
        }
        
        
        if let int = try? container.decode(Int.self, forKey: .episodeLength){
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds: int)
            episodeLength = "\(h):\(m):\(s)"
        }
        episodeDescription = try? container.decode(String.self, forKey: .episodeDescription)
        if episodeDescription == nil {
            episodeDescription = try? container.decode(String.self, forKey: .episodeDescription2)
        }
        
        episodeDescription = episodeDescription?.replacingOccurrences(of: "<p>", with: "\n \n").replacingOccurrences(of: "</p>", with: "")
        
        if let int = try? container.decode(Int.self, forKey: .episodeDate){
            ms = int
            let double = Double(int)
            // https://stackoverflow.com/questions/35700281/date-format-in-swift
            let dateFormatterGet = DateFormatter()
            let date = Date(timeIntervalSince1970: (double / 1000.0))
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            let formattedDate = dateFormatterGet.string(from: date)
            episodeDate = "\(formattedDate)"
            //            print(episodeDate)
            // https://stackoverflow.com/questions/40714893/how-to-convert-milliseconds-to-date-string-in-swift-3
        }
        
        let podcastContainer = try? container.nestedContainer(keyedBy: PodcastKeys.self, forKey: .podcast)
        
        podcastName = try? podcastContainer?.decode(String.self, forKey: .title)
        podcastID = try? podcastContainer?.decode(String.self, forKey: .id)
        
    }
    // https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
      }
}
