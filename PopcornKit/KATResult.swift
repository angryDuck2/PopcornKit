import Foundation
import ObjectMapper

public struct KATResult: Mappable, Equatable {
    
    public var id: Int!
    public var url: String!
    public var title: String!
    public var titleLong: String!
    
    public var dateUploaded: NSDate!
    
    public var torrents: [Torrent]!
    
    public init(_ map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        self.id <- map["hash"]
        self.url <- map["url"]
        self.title <- map["title"]
        self.titleLong <- map["title"]
        
        var torrent = Torrent.init(map)
        torrent.mapping(map)
        self.torrents = [torrent]
        self.dateUploaded <- map["pubDate"] //(map["date_uploaded_unix"], DateTransform())
    }
    
}

// MARK: Equatable

public func == (lhs: KATResult, rhs: KATResult) -> Bool {
    return lhs.id == rhs.id
}

public func < (lhs: KATResult, rhs: KATResult) -> Bool {
    return lhs.id < rhs.id
}

public func > (lhs: KATResult, rhs: KATResult) -> Bool {
    return lhs.id > rhs.id
}
