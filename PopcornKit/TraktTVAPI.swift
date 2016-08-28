import Foundation
import AKTrakt
import ObjectMapper

public protocol TraktTVAPIViewDelegate: class {
    /**
     Called when a user has successfully logged in
     
     - parameter controller: controller
     */
    func TraktDidAuthenticate(controller: UIViewController)
    
    /**
     Called when a user cancel the auth process
     
     - parameter controller: controller
     */
    func TraktDidCancel(controller: UIViewController)
}
public class TraktTVAPI {
    
    public var user:String?
    internal weak var delegate: TraktTVAPIViewDelegate!
    lazy var trakt: Trakt = {
        return Trakt.autoload()
    } ()
    
    public enum type: String {
        case Movies = "Movie"
        case Shows = "Show"
    }
    
    public typealias T = Mappable
    
    public class func sharedManager() -> TraktTVAPI {
        struct Struct {
            static let Instance = TraktTVAPI()
        }
        
        return Struct.Instance
    }
    
    public var favouriteIDs = [String]()
    
    private init(){
        if trakt.hasValidToken() {
            TraktRequestProfile().request(trakt) { user, error in
                self.user = user?["username"] as? String
            }
        }
    }
    
    public func getWatched(forType type: TraktTVAPI.type, completion: ([T]?) ->()) {
        
        if(trakt.hasValidToken()){
            if(type == .Movies){
                
                let traktWatchedRequest = TraktRequestGetWatchlist(type: TraktMovie.self,extended: [.Full, .Images])
                traktWatchedRequest.request(trakt){ dict, err in
                    let results = (dict?.flatMap({$0.media}))!
                    var moviesArray = [T]()
                    var movie = Movie.init(Map.init(mappingType: .FromJSON, JSONDictionary: ["":""]))
                    for result in results{
                        movie.imdbId = result.ids[TraktId.Imdb] as? String
                        movie.title = result.title
                        movie.year = result.year
                        movie.id = Int(result.id)
                        movie.largeCoverImage = result.images[TraktImageType.Poster]?[TraktImageSize.Full]?.URLString
                        movie.smallCoverImage = result.images[TraktImageType.Poster]?[TraktImageSize.Thumb]?.URLString
                        movie.mediumCoverImage = result.images[TraktImageType.Poster]?[TraktImageSize.Medium]?.URLString
                        movie.rating = result.rating
                        movie.summary = result.description
                        movie.ytTrailerCode = result.trailer
                        movie.genres = result.genres
                        movie.runtime = result.runtime
                        movie.slug = result.ids[TraktId.Slug] as? String
                        self.favouriteIDs.append(movie.imdbId)
                        moviesArray.append(movie as! Mappable)
                        
                    }
                    completion(moviesArray)
                    
                }
            }else{
                let traktWatchedRequest = TraktRequestGetWatchlist(type: TraktShow.self,extended: [.Full, .Images, .Metadata])
                traktWatchedRequest.request(trakt){ dict, err in
                    if err != nil{
                        completion(nil)
                    }
                    let results = (dict?.flatMap({$0.media}))!
                    
                    var showsArray = [T]()
                    
                    for result in results{
                        var show = Show.init(Map.init(mappingType: .FromJSON, JSONDictionary: ["":""]))
                        show.tvdbId = result.ids[TraktId.Tvdb] as? Int
                        show.title = result.title
                        show.year = String(result.year)
                        show.id = result.ids[TraktId.Imdb] as? String
                        show.bannerImage = result.images[TraktImageType.Banner]?[TraktImageSize.Full]?.URLString
                        show.fanartImage = result.images[TraktImageType.FanArt]?[TraktImageSize.Thumb]?.URLString
                        show.posterImage = result.images[TraktImageType.Poster]?[TraktImageSize.Medium]?.URLString
                        show.synopsis = result.description
                        self.favouriteIDs.append(show.id)
                        show.slug = result.ids[TraktId.Slug] as? String
                        showsArray.append(show as! Mappable)
                    }
                    completion(showsArray)
                }
            }
            
        }
    }
    
    public func authenticateUser(delegate: TraktTVAPIViewDelegate) -> UIViewController{
        if let vc = TraktAuthenticationViewController.credientialViewController(trakt, delegate: self){
            self.delegate = delegate
            return vc
        }
        return UIViewController()
    }
    
    public func getTraktMetadata(withName name:String,type: TraktTVAPI.type, completion:((TraktIdentifier)?)->()){
        if( type == .Movies){
            let search = TraktRequestMovie(id: name, extended: [.Full])
            search.request(trakt){object, error in
                if error != nil{
                    completion(nil)
                }
                completion(object!.id)
            }
        }else{
            let search = TraktRequestShow(id: name, extended: [.Full])
            search.request(trakt){object, error in
                if error != nil{
                    completion(nil)
                }
                completion(object!.id)
            }
        }
        
    }
    
    public func addToWatchlist(withType type: TraktTVAPI.type, itemID:UInt,completion:(added:Bool)->(),imdbID:String?){
        let tvtype = type == .Movies ? TraktType.Movies :TraktType.Shows
        let traktreq = TraktRequestAddToWatchlist.init(list: [tvtype:[itemID]])
        traktreq.request(trakt) { result , error in
            if(error != nil){
                print("error occured durring addition to watchlist \(error?.description)")
                completion(added:false)
            }
            
            if let added = result.flatMap({$0.added}){
                for add in added{
                    print("key \(added) value \(add)")
                    if imdbID != nil {
                        self.favouriteIDs.append(imdbID!)
                    }else{
                        self.favouriteIDs.append(String(itemID))
                    }
                    if(add.1==1){completion(added: true);return}
                }
            }
            if let existing = result.flatMap({$0.existing}){
                for add in existing{
                    print("key \(existing) value \(add)")
                    if imdbID != nil {
                        self.favouriteIDs.append(imdbID!)
                    }else{
                        self.favouriteIDs.append(String(itemID))
                    }
                    if(add.1==1){completion(added: true);return}
                }
            }
            if let notFound = result.flatMap({$0.notFound}){
                for add in notFound{
                    if(add.1.count > 0){completion(added: false)}
                    print("key \(notFound) value \(add.1)")
                }
            }
            
        }
        
    }
    
    public func removeFromWatchlist(withType type: TraktTVAPI.type, itemID:UInt,imdbID:String, completion:(removed:Bool)->()){
        let tvtype = type == .Movies ? TraktType.self.Movies : TraktType.self.Shows
        let traktreq = TraktRequestRemoveFromWatchlist.init(list: [tvtype:[itemID]])
        traktreq.request(trakt) { (result, error) in
            if(error != nil){
                print("error occured durring addition to watchlist \(error?.description)")
                completion(removed: false)
            }
            
            if let deleted = result.flatMap({$0.deleted}){
                for delete in deleted{
                    print("key \(deleted) value \(delete)")
                    self.favouriteIDs.removeAtIndex(self.favouriteIDs.indexOf(imdbID)!)
                    if(delete.1==1){completion(removed: true);return}
                }
            }
            if let notFound = result.flatMap({$0.notFound}){
                for found in notFound{
                    print("key \(notFound) value \(found)")
                    if found.1.count>0 {completion(removed: false)}
                }
            }
            
        }
        
    }
    
    public func isFavourite(id: String!) -> Bool{
        if favouriteIDs.contains(id){
            return true
        }
        return false
    }
    
    public func clearToken() {
        trakt.clearToken()
    }
    
    public func userLoaded() -> Bool{
        if trakt.hasValidToken() {
            return true
        }
        return false
    }
    
}
extension TraktTVAPI: TraktAuthViewControllerDelegate {
    public func TraktAuthViewControllerDidAuthenticate(controller: UIViewController) {
        TraktRequestProfile().request(trakt) { user, error in
            self.user = user?["username"] as? String
        }
        self.delegate.TraktDidAuthenticate(controller)
        
        
        
    }
    
    public func TraktAuthViewControllerDidCancel(controller: UIViewController) {
        self.delegate.TraktDidAuthenticate(controller)
    }
}
