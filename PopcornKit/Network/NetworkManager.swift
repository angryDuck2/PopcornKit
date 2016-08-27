import Foundation
import Alamofire
import ObjectMapper
import SWXMLHash

private var YTSBase = ""
private struct YTS {
    static let ListMovies = "list_movies.json"
    static let MovieDetails = "movie_details.json"
    static let Suggestions = "movie_suggestions.json"
    static let Upcoming = "list_upcoming.json"
}

// Using this https://github.com/popcorn-official/popcorn-api // https://api-fetch.website/tv/
private var EZTVBase = ""
private struct EZTV {
    static let ShowPages = "shows/"
    static let ShowDetails = "show/"
    static let Search = "shows/search/"
}

private struct TVDB {
    static let APIKey = "9E34AA6080FCEA35"
    static let Base = "http://thetvdb.com/api/"
    static let Series = Base + APIKey + "/series/"
    static let Episodes = Base + APIKey + "/episodes/"
}

private struct Trakt {
    static let APIKey = "aba241fadf8dafe38b67adb45d995770fee2540abb8936021611c4fd4adea40b"
    static let Base = "https://api-v2launch.trakt.tv/"
    static let Shows = "/shows/"
    static let People = "people/"
    static let Season = "/seasons/"
    static let Episodes = "/episodes/"
    static let Parameters = ["extended" : "images"]
    static let Headers = [
        "Content-Type": "application/json",
        "trakt-api-version": "2",
        "trakt-api-key": Trakt.APIKey
    ]
}

private var KATBase = ""
private struct KAT {
    static let Search = "json.php?"
    static let ListMovies = "category:movies"
    static let ListShows = "category:tv"
}


public class NetworkManager {
    
    private var manager: Alamofire.Manager!
    
    public class func sharedManager() -> NetworkManager {
        struct Struct {
            static let Instance = NetworkManager()
        }
        
        return Struct.Instance
    }
    
    private init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPCookieAcceptPolicy = .Always
        configuration.HTTPShouldSetCookies = true
        configuration.URLCache = nil
        configuration.requestCachePolicy = .UseProtocolCachePolicy
        
        self.manager = Alamofire.Manager(configuration: configuration)
    }
    
    // MARK: Servers
    
    public func fetchServers(completion: ((servers: [String : AnyObject]?, error: NSError?) -> Void)?) {
        self.manager.request(.GET, "https://raw.githubusercontent.com/PopcornTimeTV/PopcornKit/master/servers.json?token=ACCdFXhygIGETS2x_rP9efYnkXAoY72oks5W9HTpwA%3D%3D")
            .responseJSON { response in
                if let response = response.result.value as? [String : AnyObject] {
                    completion?(servers: response, error: nil)
                } else {
                    completion?(servers: nil, error: response.result.error)
                }
        }
    }
    
    public func setServerEndpoints(yts yts: String, eztv: String, kat: String) {
        YTSBase = yts
        EZTVBase = eztv
        KATBase = kat
    }
    
    // MARK: Public (KAT)
    
    public func fetchKATResults(page page: Int, queryTerm: String?, genre: String?, category: String?, sortBy: String, orderBy: String, completion: ((movies: [KATResult]?, error: NSError?) -> Void)?){
        let params = self.buildKATMovieParameters(page: page, queryTerm: queryTerm, genre: genre, category: category, sortBy: sortBy, orderBy: orderBy)
        self.manager.request(.GET, KATBase + KAT.Search , parameters: params)
            .responseJSON { response in
                if let response = response.result.value as? [String : AnyObject] {
                    if let movies = response["list"] as? [[String : AnyObject]] {
                        if let movieArray = Mapper<KATResult>().mapArray(movies) {
                            completion?(movies: movieArray, error: nil)
                            
                        }
                    }
                } else {
                    completion?(movies: nil, error: response.result.error)
                }
        }
    }
    
    // MARK: Public (YTS)
    
    public func fetchMovies(limit limit: Int, page: Int, quality: String?, minimumRating: Int, queryTerm: String?, genre: String?, sortBy: String, orderBy: String, withImages: Bool = false, completion: ((movies: [Movie]?, error: NSError?) -> Void)?) {
        let params = self.buildMovieParameters(limit, page: page, quality: quality, minimumRating: minimumRating, queryTerm: queryTerm, genre: genre, sortBy: sortBy, orderBy: orderBy, withImages: withImages)
        self.manager.request(.GET, YTSBase + YTS.ListMovies, parameters: params)
            .responseJSON { response in
                if let response = response.result.value as? [String : AnyObject] {
                    if let data = response["data"] as? [String : AnyObject] {
                        if let movies = data["movies"] as? [[String : AnyObject]] {
                            if let movieArray = Mapper<Movie>().mapArray(movies) {
                                completion?(movies: movieArray, error: nil)
                            }
                        }
                    }
                } else {
                    completion?(movies: nil, error: response.result.error)
                }
        }
    }
    
    
    public func showDetailsForMovie(movieId movieId: Int, withImages: Bool, withCast: Bool, completion: ((movie: Movie?, error: NSError?) -> Void)?) {
        let params = self.showMovieParameters(movieId: movieId, withImages: withImages, withCast: withCast)
        self.manager.request(.GET, YTSBase + YTS.MovieDetails, parameters: params)
            .responseJSON { response in
                if let response = response.result.value as? [String : AnyObject] {
                    if let movie = response["data"] as? [String : AnyObject] {
                        completion?(movie: Mapper<Movie>().map(movie), error: nil)
                    }
                } else {
                    completion?(movie: nil, error: response.result.error)
                }
        }
    }
    
    public func suggestionsForMovie(movieId movieId: Int, completion: ((movies: [Movie]?, error: NSError?) -> Void)?) {
        let parameters = self.indexSuggestionsParameters(movieId: movieId)
        self.manager.request(.GET, YTSBase + YTS.Suggestions, parameters: parameters)
            .responseJSON { response in
                if let response = response.result.value as? [String : AnyObject] {
                    if let data = response["data"] as? [String : AnyObject] {
                        if let movies = data["movie_suggestions"] as? [[String : AnyObject]] {
                            if let movieArray = Mapper<Movie>().mapArray(movies) {
                                completion?(movies: movieArray, error: nil)
                            }
                        }
                    }
                } else {
                    completion?(movies: nil, error: response.result.error)
                }
        }
    }
    
    // Mark: Public (Actor/Director Credits)
    
    public func getCreditsForPerson(actorName actorName: String, isActor isActor: Bool, completion: ((movies: [Movie]?, shows: [Show]?, error: NSError?) -> Void)?) {
        
        getImdbIdofActor(actorName: actorName) { (imdbCode, error) in
            if error != nil {
                completion?(movies: nil, shows: nil, error: error)
            }
            self.getMoviesOfActor(imdbId: imdbCode!, isActor: isActor, completion: { (movies, error) in
                if error != nil {
                    completion?(movies: nil, shows: nil, error: error)
                }
                self.getShowsOfActor(imdbId: imdbCode!, isActor: isActor, completion: { (shows, error) in
                    if error != nil {
                        completion?(movies: nil, shows: nil, error: error)
                    }
                    completion?(movies: movies, shows: shows, error: nil)
                })
            })
        }
        
    }
    
    // Mark: Private (Actor/Director Credits)
    
    private func getMoviesOfActor(imdbId imdbId: String, isActor isActor: Bool = true, completion: ((movies: [Movie]?, error: NSError?) -> Void)?) {
        var formattedMovies = [Movie]()
        let tasker = dispatch_group_create()
        
        self.manager.request(.GET, Trakt.Base + Trakt.People + imdbId + "/movies", parameters: nil, encoding: .URL, headers: Trakt.Headers)
            .responseJSON { response in
                if let result = response.result.value as? [String : AnyObject] {
                    
                    var moviesResponse: AnyObject?
                    if(isActor) {
                        moviesResponse = result["cast"]
                    }else{
                        moviesResponse = result["crew"]!["directing"]
                        if moviesResponse == nil {
                            completion?(movies: nil, error: nil)
                        }
                    }
                    
                    if let moviesResponse = moviesResponse {
                        for movie in moviesResponse as! [[String: AnyObject]] {
                            let imdbId = movie["movie"]!["ids"]!!["imdb"] as? String
                            if(imdbId == nil) {
                                continue
                            }
                            
                            dispatch_group_enter(tasker)
                            NetworkManager.sharedManager().fetchMovies(limit: 1, page: 1, quality: nil, minimumRating: 0, queryTerm: imdbId!, genre: nil, sortBy: "seeds", orderBy: "desc") { movies, error in
                                if let movies = movies {
                                    if(movies.first != nil) {
                                        formattedMovies.append(movies.first!)
                                    }
                                }
                                dispatch_group_leave(tasker)
                            }
                        }
                        
                        dispatch_group_notify(tasker, dispatch_get_main_queue(), {
                            completion?(movies: formattedMovies, error: nil)
                        })
                    }
                    
                    
                }else{
                    completion?(movies: nil, error: response.result.error)
                }
        }
    }
    
    private func getShowsOfActor(imdbId imdbId: String, isActor isActor: Bool = true, completion: ((shows: [Show]?, error: NSError?) -> Void)?) {
        var formattedShows = [Show]()
        let tasker = dispatch_group_create()
        
        self.manager.request(.GET, Trakt.Base + Trakt.People + imdbId + "/shows", parameters: nil, encoding: .URL, headers: Trakt.Headers)
            .responseJSON { response in
                if let result = response.result.value as? [String : AnyObject] {
                    
                    var showResponse: AnyObject?
                    if(isActor) {
                        showResponse = result["cast"]
                    }else{
                        completion?(shows: nil, error: nil)
                    }
                    
                    if let showResponse = showResponse {
                        for show in showResponse as! [[String: AnyObject]]  {
                            
                            let imdbId = show["show"]!["ids"]!!["imdb"] as? String
                            
                            if(imdbId == nil) {
                                continue
                            }
                            
                            dispatch_group_enter(tasker)
                            self.fetchShowDetails(imdbId!, completion: { (show, error) in
                                if let show = show {
                                    if(show.title != nil) {
                                        formattedShows.append(show)
                                    }
                                }
                                dispatch_group_leave(tasker)
                            })
                            
                        }
                        
                        dispatch_group_notify(tasker, dispatch_get_main_queue(), {
                            completion?(shows: formattedShows, error: nil)
                        })
                    }
                    
                }else{
                    completion?(shows: nil, error: response.result.error)
                }
        }
    }
    
    private func getImdbIdofActor(actorName actorName: String, completion: ((imdbCode: String?, error: NSError?) -> Void)?) {
        
        var actorString = "http://www.imdb.com/xml/name?json=1&nr=1&nm=on&q="+actorName
        actorString = actorString.stringByReplacingOccurrencesOfString(" ", withString: "+")
        actorString = actorString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        self.manager.request(.GET, actorString, parameters: nil) // Get fucking IMDB ID of Actor/Director
            .responseJSON { response in
                if let response = response.result.value as? [String : AnyObject] {
                    
                    if(response["name_popular"] != nil) {
                        let imdbSlug = (response["name_popular"] as! [[String : AnyObject]])[0]["id"] as! String
                        completion?(imdbCode: imdbSlug, error: nil)
                    }else{
                        if let nameexact = response["name_exact"] as? [[String: AnyObject]] {
                            if let imdbSlug = nameexact[0]["id"] as? String {
                                completion?(imdbCode: imdbSlug, error: nil)
                            }else{
                                completion?(imdbCode: nil, error: nil)
                            }
                        }else{
                            completion?(imdbCode: nil, error: nil)
                        }
                    }
                    
                }else{
                    completion?(imdbCode: nil, error: response.result.error)
                }
        }
    }
    
    // MARK: Private (YTS)
    
    private func buildMovieParameters(limit: Int = 20, page: Int = 1, quality: String? = nil, minimumRating: Int = 0, queryTerm: String? = nil, genre: String? = nil, sortBy: String = "date_added", orderBy: String = "desc", withImages: Bool = false) -> [String: AnyObject] {
        var parameters = [String: AnyObject]()
        parameters["limit"] = limit
        parameters["page"] = page
        
        if let quality = quality {
            parameters["quality"] = quality
        }
        
        parameters["minimum_rating"] = minimumRating
        
        if let queryTerm = queryTerm {
            parameters["query_term"] = queryTerm
        }
        
        if let genre = genre {
            parameters["genre"] = genre
        }
        
        parameters["sort_by"] = sortBy
        parameters["order_by"] = orderBy
        parameters["with_images"] = withImages ? "true" : "false"
        
        return parameters
    }
    
    // MARK: Private (KAT)
    
    private func buildKATMovieParameters(page page: Int = 1, queryTerm: String? = nil, genre: String? = nil, category: String? = nil, sortBy: String = "date_added", orderBy: String = "desc") -> [String: AnyObject] {
        var parameters = [String: AnyObject]()
        
        parameters["page"] = page
        
        if let queryTerm = queryTerm {
            parameters["q"] = queryTerm.stringByAppendingString(" verified:true")
        }
        
        if let category = category {
            let categoryQuery = category == "movies" ? KAT.ListMovies : KAT.ListShows
            parameters["q"] = parameters["q"]?.stringByAppendingString(" " + categoryQuery)
        }
        
        if let genre = genre {
            parameters["q"] = parameters["q"]?.stringByAppendingString(" " + genre)
        }
        
        parameters["field"] = sortBy
        parameters["order"] = orderBy
        
        return parameters
    }
    
    
    private func showMovieParameters(movieId movieId: Int, withImages: Bool = false, withCast: Bool = false) -> [String: AnyObject] {
        var parameters = [String: AnyObject]()
        parameters["movie_id"] = movieId
        parameters["with_images"] = withImages ? "true" : "false"
        parameters["with_cast"] = withCast ? "true" : "false"
        return parameters
    }
    
    private func indexSuggestionsParameters(movieId movieId: Int) -> [String: AnyObject] {
        return ["movie_id": movieId]
    }
    
    // MARK: Public (EZTV)
    
    public func fetchShowPageNumbers(completion: ((pageNumbers: [Int]?, error: NSError?) -> Void)?) {
        self.manager.request(.GET, EZTVBase + EZTV.ShowPages)
            .responseJSON { response in
                if let pages = response.result.value as? [String] {
                    var pageNumbers = [Int]()
                    for page in pages {
                        if let number = page.componentsSeparatedByString("shows/").last {
                            if let numberAsInt = Int(number) {
                                pageNumbers.append(numberAsInt)
                            }
                        }
                    }
                    
                    pageNumbers.sortInPlace({ $0 < $1 })
                    completion?(pageNumbers: pageNumbers, error: nil)
                } else {
                    completion?(pageNumbers: nil, error: response.result.error)
                }
        }
    }
    
    public func fetchShowsForPage(pageNumber: Int, completion: ((shows: [Show]?, error: NSError?) -> Void)?) {
        self.manager.request(.GET, EZTVBase + EZTV.ShowPages + "\(pageNumber)")
            .responseJSON { response in
                if let shows = response.result.value as? [[String : AnyObject]] {
                    completion?(shows: Mapper<Show>().mapArray(shows), error: nil)
                } else {
                    completion?(shows: nil, error: response.result.error)
                }
        }
    }
    
    public func fetchShowDetails(showId: String, completion: ((show: Show?, error: NSError?) -> Void)?) {
        self.manager.request(.GET, EZTVBase + EZTV.ShowDetails + showId)
            .responseJSON { response in
                if let data = response.result.value as? [String : AnyObject] {
                    if let episodes = data["episodes"] as? [[String : AnyObject]] {
                        var mutableEpisodes = episodes
                        for (index, episode) in mutableEpisodes.enumerate() {
                            var newTorrents = [[String : AnyObject]]()
                            if let torrents = episode["torrents"] as? [String : AnyObject] {
                                for (key, value) in torrents {
                                    if let value = value as? [String : AnyObject] {
                                        var mutableValue = value
                                        mutableValue["quality"] = key
                                        newTorrents.append(mutableValue)
                                    }
                                }
                            }
                            mutableEpisodes[index]["torrents"] = newTorrents
                        }
                        var show = Mapper<Show>().map(data)
                        show?.episodes = Mapper<Episode>().mapArray(mutableEpisodes)
                        
                        completion?(show: show, error: nil)
                    }
                } else {
                    completion?(show: nil, error: response.result.error)
                }
        }
    }
    
    public func fetchShows(pages: [Int], searchTerm: String? = nil, genre: String? = nil, sort: String? = nil, order: String? = nil, completion: ((shows: [Show]?, error: NSError?) -> Void)?) {
        var parameters = [String: String]()
        if let searchTerm = searchTerm {
            parameters["keywords"] = searchTerm
        }
        if let genre = genre {
            parameters["genre"] = genre
        }
        
        if let sort = sort {
            parameters["sort"] = sort
        }
        
        if let order = order {
            parameters["order"] = order
        }
        
        
        var allShows = [Show]()
        let group = dispatch_group_create()
        
        for page in pages {
            dispatch_group_enter(group)
            self.manager.request(.GET, EZTVBase + EZTV.ShowPages + "\(page)", parameters: parameters)
                .responseJSON { response in
                    if let shows = response.result.value as? [[String : AnyObject]] {
                        if let items = Mapper<Show>().mapArray(shows) {
                            allShows += items
                            dispatch_group_leave(group)
                        }
                    }
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completion?(shows: allShows, error: nil)
        }
    }
    
    // MARK: TVDB
    
    public func searchTVDBSeries(showId: Int, completion: ((response: XMLIndexer?, error: NSError?) -> Void)?) {
        self.manager.request(.GET, TVDB.Series + "\(showId)")
            .responseData { response in
                if let data = response.data {
                    let xml = SWXMLHash.parse(data)
                    completion?(response: xml, error: nil)
                } else {
                    completion?(response: nil, error: response.result.error)
                }
        }
    }
    
    public func searchTVDBEpisodes(episodeId: Int, completion: ((response: XMLIndexer?, error: NSError?) -> Void)?) {
        self.manager.request(.GET, TVDB.Episodes + "\(episodeId)")
            .responseData { response in
                if let data = response.data {
                    let xml = SWXMLHash.parse(data)
                    completion?(response: xml, error: nil)
                } else {
                    completion?(response: nil, error: response.result.error)
                }
        }
    }
    
    // MARK: Trakt
    
    public func fetchTraktSeasonInfoForIMDB(imdbSlug: String, completion: ((response: [[String : AnyObject]]?, error: NSError?) -> Void)?) {
        self.manager.request(.GET, Trakt.Base + Trakt.Shows + imdbSlug + Trakt.Season, parameters: Trakt.Parameters, encoding: .URL, headers: Trakt.Headers)
            .responseJSON { response in
                if let data = response.result.value as? [[String : AnyObject]] {
                    completion?(response: data, error: nil)
                } else {
                    completion?(response: nil, error: response.result.error)
                }
        }
    }
    
    public func fetchTraktSeasonEpisodesInfoForIMDB(imdbSlug: String, season: Int, completion: ((response: [[String : AnyObject]]?, error: NSError?) -> Void)?) {
        self.manager.request(.GET, Trakt.Base + Trakt.Shows + imdbSlug + Trakt.Season + String(season) + Trakt.Episodes, parameters: Trakt.Parameters, encoding: .URL, headers: Trakt.Headers)
            .responseJSON { response in
                if let data = response.result.value as? [[String : AnyObject]] {
                    completion?(response: data, error: nil)
                } else {
                    completion?(response: nil, error: response.result.error)
                }
        }
    }
    
    public func fetchTraktSeasonEpisodeInfoForIMDB(imdbSlug: String, season: Int, episode: Int, completion: ((response: [String : AnyObject]?, error: NSError?) -> Void)?) {
        self.manager.request(.GET, Trakt.Base + Trakt.Shows + imdbSlug + Trakt.Season + String(season) + Trakt.Episodes + String(episode), parameters: Trakt.Parameters, encoding: .URL, headers: Trakt.Headers)
            .responseJSON { response in
                if let data = response.result.value as? [String : AnyObject] {
                    completion?(response: data, error: nil)
                } else {
                    completion?(response: nil, error: response.result.error)
                }
        }
    }
    
    public func fetchTraktFanartForIMDB(imdbSlug: String, completion: ((response: [String : AnyObject]?, error: NSError?) -> Void)?) {
        self.manager.request(.GET, Trakt.Base + Trakt.Shows + imdbSlug, parameters: Trakt.Parameters, encoding: .URL, headers: Trakt.Headers)
            .responseJSON { response in
                if let data = response.result.value as? [String : AnyObject] {
                    completion?(response: data, error: nil)
                } else {
                    completion?(response: nil, error: response.result.error)
                }
        }
    }
    
    func fetchShowCastInfoForIMDB(imdbId: String, completion: ((actors: Actor?..., error: NSError?) -> Void)?) {
        self.manager.request(.GET, Trakt.Base + Trakt.Shows + imdbId + Trakt.People, parameters: Trakt.Parameters, encoding: .URL, headers: Trakt.Headers)
            .responseJSON { response in
                guard let value = response.result.value as? [String: AnyObject] else {completion?(actors: nil, error: response.result.error!); return}
                completion?(actors: Mapper<Actor>().map(value), error: nil)
        }
    }
}
