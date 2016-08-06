import Foundation
import TVServices

public enum AppURL {

    case Movie(movieId: Int)
    case Unknown


    // MARK: - Init

    init(url: NSURL) {
        if url.absoluteString.containsString("popcorn://movies/") {
            let movieId =  url.absoluteString.stringByReplacingOccurrencesOfString("popcorn://movies/", withString: "")
            self = AppURL.Movie(movieId: Int(movieId)!)
        } else {
            self = AppURL.Unknown
        }
    }


    // MARK: - Public

    /**
    Generates the App NSURL.

    - returns: NSURL that can be processed by the app.
    */
    public func toURL() -> NSURL? {
        switch self {
        case .Movie(let movieId):
            return NSURL(string: "popcorn://movies/\(movieId)")
        case .Unknown:
            return nil
        }
    }
}

/**
 *  Adapts a Movie into a TVContentItem
 */
public struct MovieContentItem {

    // MARK: Init

    public init() {

    }


    // MARK: Public

    /**
    Adapts the movie into a TVContentItem.

    - parameter movie: Movie to be adapted.

    - returns: Created TVContentItem from the Movie.
    */
    public func adapt(movie: Movie) -> TVContentItem {
        let contentItem = TVContentItem(contentIdentifier: TVContentIdentifier(identifier: "\(movie.id)", container: nil)!)!
        contentItem.imageURL = NSURL(string: movie.largeCoverImage)
        contentItem.imageShape = TVContentItemImageShape.Poster
        contentItem.title = movie.title
        contentItem.duration = movie.runtime * 60
        contentItem.displayURL = AppURL.Movie(movieId: movie.id).toURL()
        return contentItem
    }

}
