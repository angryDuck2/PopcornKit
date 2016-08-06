import Foundation
import ObjectMapper

extension String {
    func sliceFrom(start: String, to: String) -> String? {
        return (rangeOfString(start)?.endIndex).flatMap { sInd in
            let eInd = rangeOfString(to, range: sInd..<endIndex)
            if eInd != nil {
                return (eInd?.startIndex).map { eInd in
                    return substringWithRange(sInd..<eInd)
                }
            }
            return substringWithRange(sInd..<endIndex)
        }
    }
}

public struct Torrent: Mappable, Equatable {
    
    private var trackers: String {
        return Trackers.map { $0 }.joinWithSeparator("&tr=")
    }
    
    public var magnet: String {
        get {
            return "magnet:?xt=urn:btih:\(self.hash)&tr=" + self.trackers //&dn=Movie+Name (URL Encoded)
        }
    }
    public var url: String!
    public var hash: String!
    public var quality: String!
    public var seeds: Int!
    public var peers: Int!
    public var size: String!
    public var sizeBytes: Int!
    public var dateUploaded: NSDate!
    
    public init(_ map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        self.url <- map["url"]
        if(self.url==nil){
            self.url <- map["link"]
        }
        self.hash <- map["hash"]
        if self.hash == nil {
            if let url = self.url {
                if url.containsString("&dn=") {
                    self.hash = url.sliceFrom("magnet:?xt=urn:btih:", to: "&dn=")
                } else {
                    self.hash = url.sliceFrom("magnet:?xt=urn:btih:", to: "")
                }
            }
        }
        self.quality <- map["quality"]
        if(self.quality==nil){
            self.quality <- map["title"]
            if(self.quality.containsString("1080p") || self.quality.containsString("1080P")){
                self.quality="1080p"
            }else if(self.quality.containsString("720p") || self.quality.containsString("HD") || self.quality.containsString("hd")){self.quality="720p"
            }else{
                self.quality="480p"
            }
        }
        self.seeds <- map["seeds"]
        self.peers <- map["peers"]
        self.size <- map["size"]
        self.sizeBytes <- map["size_bytes"]
        self.dateUploaded <- (map["date_uploaded_unix"], DateTransform())
    }
}

public func == (lhs: Torrent, rhs: Torrent) -> Bool {
    return lhs.hash == rhs.hash
}
