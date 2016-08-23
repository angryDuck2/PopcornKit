import Foundation
import ObjectMapper

public struct Episode: Mappable, Equatable {
    
    public var dateBased: Bool!
    public var firstAirDate: NSDate!
    public var overview: String!
    public var title: String!
    public var season: Int!
    public var episode: Int!
    public var torrents: [Torrent]!
    public var tvdbId: Int!
    
    public init(_ map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        self.dateBased <- map["date_based"]
        self.firstAirDate <- (map["first_aired"], DateTransform())
        self.overview <- map["overview"]
        self.title <- map["title"]
        var temp: String!;
        temp <- map["season"]
        if temp != nil{
            self.season = NSNumberFormatter().numberFromString(temp)?.integerValue
        }else{
            self.season <- map["season"]
        }
        temp <- map["episode"]
        if temp != nil{
            self.episode = NSNumberFormatter().numberFromString(temp)?.integerValue
        }else{
            self.episode <- map["episode"]
        }
        self.torrents <- map["torrents"]
        temp <- map["tvdb_id"]
        if temp != nil{
            self.tvdbId = NSNumberFormatter().numberFromString(temp)?.integerValue
        }else{
            self.tvdbId <- map["tvdb_id"]
        }
    }
    
}

public func == (lhs: Episode, rhs: Episode) -> Bool {
    return lhs.season == rhs.season && lhs.episode == rhs.episode
}

public func > (lhs: Episode, rhs: Episode) -> Bool {
    return lhs.season > rhs.season && lhs.episode > rhs.episode
}

public func < (lhs: Episode, rhs: Episode) -> Bool {
    return lhs.season < rhs.season && lhs.episode < rhs.episode
}
