import Foundation
import ObjectMapper

public struct Actor: Mappable {

    public var name: String!
    public var characterName: String!
    public var mediumImage: String!
    public var smallImage: String!
    public var imdbCode: Int!

    public init(_ map: Map) {

    }

    public mutating func mapping(map: Map) {
        self.name <- map["name"]
        self.characterName <- map["character_name"]
        self.mediumImage <- map["medium_image"]
        self.smallImage <- map["small_image"]
        self.imdbCode <- map["imdb_code"]
    }

}
