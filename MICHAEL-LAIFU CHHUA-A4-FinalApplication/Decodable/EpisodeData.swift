//
//  Result.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 1/5/21.
//

import UIKit

class EpisodeData: NSObject, Decodable, NSCoding {
//    https://stackoverflow.com/questions/28240848/how-to-save-an-array-of-objects-to-nsuserdefault-with-swift/48438338#48438338
    func encode(with coder: NSCoder) {
        coder.encode(audio, forKey: "audio")
        coder.encode(image, forKey: "image")
        coder.encode(title, forKey: "title")
        coder.encode(episodeLength, forKey: "episodeLength")
        coder.encode(episodeDescription, forKey: "episodeDescription")
        coder.encode(episodeDate, forKey: "episodeDate")
        coder.encode(podcastName, forKey: "podcastName")
        coder.encode(podcastID, forKey: "podcastID")
        coder.encode(ms, forKey: "ms")
    }
    
    required init?(coder: NSCoder) {
        self.audio = coder.decodeObject(forKey: "audio") as? String
        self.image = coder.decodeObject(forKey: "image") as? String
        self.title = coder.decodeObject(forKey: "title") as? String
        self.episodeLength = coder.decodeObject(forKey: "episodeLength") as? String
        self.episodeDescription = coder.decodeObject(forKey: "episodeDescription") as? String
        self.episodeDate = coder.decodeObject(forKey: "episodeDate") as? String
        self.podcastName = coder.decodeObject(forKey: "podcastName") as? String
        self.podcastID = coder.decodeObject(forKey: "podcastID") as? String
        self.ms = coder.decodeObject(forKey: "ms") as? Int
    }
    
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
            
            // padding with zero if required
            var stringM = "\(m)"
            if stringM.count < 2{
                stringM = "0\(m)"
            }
            
            var stringS = "\(s)"
            if stringS.count < 2{
                stringS = "0\(s)"
            }
            episodeLength = "\(h)h \(stringM)m \(stringS)s"
        }
        episodeDescription = try? container.decode(String.self, forKey: .episodeDescription)
        if episodeDescription == nil {
            episodeDescription = try? container.decode(String.self, forKey: .episodeDescription2)
        }
        
        
        
        if let int = try? container.decode(Int.self, forKey: .episodeDate){
            ms = int
            let double = Double(int)
            // https://stackoverflow.com/questions/35700281/date-format-in-swift
            let dateFormatterGet = DateFormatter()
            let date = Date(timeIntervalSince1970: (double / 1000.0))
            dateFormatterGet.dateFormat = "dd-MM-yyyy"
            let formattedDate = dateFormatterGet.string(from: date)
            episodeDate = "\(formattedDate)"
            
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

