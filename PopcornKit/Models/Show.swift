import Foundation
import ObjectMapper

public struct ShowRating: Mappable {

    public var hated: Int!
    public var loved: Int!
    public var percentage: Int!
    public var votes: Int!
    public var watching: Int!

    public init(_ map: Map) {

    }

    public mutating func mapping(map: Map) {
        self.hated <- map["hated"]
        self.loved <- map["loved"]
        self.percentage <- map["percentage"]
        self.votes <- map["votes"]
        self.watching <- map["watching"]
    }
}

public struct Show: Mappable, Equatable {

    public var id: String!

    public var bannerImage: String!
    public var fanartImage: String!
    public var posterImage: String!

    public var imdbId: Int!

    public var lastUpdated: NSDate!

    public var numberOfSeasons: Int!

    public var rating: ShowRating!

    public var slug: String!
    public var title: String!

    public var tvdbId: Int!

    public var year: String!

    // Only used when fetching info from episodes
    public var airDay: String!
    public var airTime: String!
    public var synopsis: String!

    // Only used when searching EZTV
    public var episodes: [Episode]!

    public init(_ map: Map) {

    }

    public mutating func mapping(map: Map) {
        self.id <- map["_id"]

        self.bannerImage <- map["images.banner"]
        self.fanartImage <- map["images.fanart"]
        self.posterImage <- map["images.poster"]

        self.imdbId <- (map["imdb_id"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))

        self.lastUpdated <- (map["last_updated"], DateTransform())

        self.numberOfSeasons <- map["num_seasons"]

        self.rating <- map["rating"]

        self.slug <- map["slug"]
        self.title <- map["title"]

//        self.tvdbId <- (map["tvdb_id"], TransformOf<Int, String>(fromJSON: { Int(id!) }, toJSON: { $0.map { String($0) } }))
        self.tvdbId <- (map["tvdb_id"], TransformOf<Int, String>(fromJSON: { string -> Int? in
            if let string = string {
                return Int(string)
            }
            return 0
        }, toJSON: { int -> String? in
            return String(int)
        }))

        self.year <- map["year"]

        self.airDay <- map["air_day"]
        self.airTime <- map["air_time"]
        self.synopsis <- map["synopsis"]
    }
}

public func == (lhs: Show, rhs: Show) -> Bool {
    return lhs.id == rhs.id
}

public func > (lhs: Show, rhs: Show) -> Bool {
    return lhs.id > rhs.id
}

public func < (lhs: Show, rhs: Show) -> Bool {
    return lhs.id < rhs.id
}
