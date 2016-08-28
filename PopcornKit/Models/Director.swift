import Foundation
import ObjectMapper

public struct Director: Mappable {

    public var name: String!
    public var mediumImage: String!
    public var smallImage: String!
    public var imdbCode: Int!

    public init(_ map: Map) {

    }

    public mutating func mapping(map: Map) {
        self.name <- map["name"]
        if self.name == nil {
            self.name <- map["person.name"]
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
            self.imdbCode <- map["person.ids.4.imdb"]
        }
    }

}
