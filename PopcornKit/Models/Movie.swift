import Foundation
import ObjectMapper

public struct Movie: Mappable, Equatable {

    public var id: Int!
    public var imdbId: String!
    public var url: String!
    public var title: String!
    public var titleEnglish: String!
    public var titleLong: String!
    public var slug: String!
    public var year: Int!
    public var rating: Float!
    public var runtime: Int!
    public var genres: [String]!
    public var summary: String!
    public var descriptionFull: String!
    public var ytTrailerCode: String!
    public var youtubeTrailerURL: String { get { return "https://www.youtube.com/watch?v=" + self.ytTrailerCode } }
    public var language: String!

    public var mpaRating: String!
    public var tomatoesCriticsRating: String!
    public var tomatoesCriticsScore: Int!
    public var tomatoesAudienceRating: String!
    public var tomatoesAudienceScore: Int!

    public var backgroundImage: String!
    public var smallCoverImage: String!
    public var mediumCoverImage: String!
    public var largeCoverImage: String!
    public var dateUploaded: NSDate!

    public var directors: [Director]!
    public var actors: [Actor]!
    public var torrents: [Torrent]!

    public init(_ map: Map) {

    }

    public mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.imdbId <- map["imdb_code"]
        self.url <- map["url"]
        self.title <- map["title"]
        self.titleEnglish <- map["title_english"]
        self.titleLong <- map["title_long"]
        self.slug <- map["slug"]
        self.year <- map["year"]
        self.rating <- map["rating"]
        self.runtime <- map["runtime"]
        self.genres <- map["genres"]
        self.summary <- map["description_intro"]
        self.descriptionFull <- map["description_full"]
        self.ytTrailerCode <- map["yt_trailer_code"]
        self.language <- map["language"]

        self.mpaRating <- map["mpa_rating"]
        self.tomatoesCriticsRating <- map["rt_critics_rating"]
        self.tomatoesCriticsScore <- map["rt_critics_score"]
        self.tomatoesAudienceRating <- map["rt_audience_rating"]
        self.tomatoesAudienceScore <- map["rt_audience_score"]

        // Hacky-ness
        self.backgroundImage <- map["images.background_image"]
        if self.backgroundImage == nil {
            self.backgroundImage <- map["background_image"]
        }

        self.smallCoverImage <- map["images.small_cover_image"]
        if self.smallCoverImage == nil {
            self.smallCoverImage <- map["small_cover_image"]
        }

        self.mediumCoverImage <- map["images.medium_cover_image"]
        if self.mediumCoverImage == nil {
            self.mediumCoverImage <- map["medium_cover_image"]
        }

        self.largeCoverImage <- map["images.large_cover_image"]
        if self.largeCoverImage == nil {
            self.largeCoverImage <- map["large_cover_image"]
        }

        self.directors <- map["directors"]
        self.actors <- map["actors"]
        self.torrents <- map["torrents"]
        self.dateUploaded <- map["date_uploaded"] //(map["date_uploaded_unix"], DateTransform())
    }

}

// MARK: Equatable

public func == (lhs: Movie, rhs: Movie) -> Bool {
    return lhs.id == rhs.id
}

public func < (lhs: Movie, rhs: Movie) -> Bool {
    return lhs.id < rhs.id
}

public func > (lhs: Movie, rhs: Movie) -> Bool {
    return lhs.id > rhs.id
}
