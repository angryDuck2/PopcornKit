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
        self.name <- map["name"]//eztv show format
        if self.name == nil {
            self.name <- map["person.name"]//trakt show format
        }
        self.characterName <- map["character_name"]
        if self.characterName == nil{
            self.characterName <- map["character"]
        }
        self.mediumImage <- map["medium_image"]
        if self.mediumImage == nil{
            self.mediumImage <- map["person.images.headshot.medium"]
        }
        self.smallImage <- map["small_image"]
        if self.smallImage == nil{
            self.smallImage <- map["person.images.headshot.thumb"]
        }
        self.imdbCode <- map["imdb_code"]
        if self.imdbCode == nil{
            self.imdbCode <- map["person.ids.imdb"]
        }
    }

}
