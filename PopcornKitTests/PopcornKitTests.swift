
import XCTest
@testable import PopcornKit

class PopcornKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    // MARK: Servers
    
    func testServerFetching() {
        let expectation = self.expectationWithDescription("Servers Request")
        
        NetworkManager.sharedManager().fetchServers { servers, error in
            XCTAssertNotNil(servers, "No results found")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    // MARK: YTS
    
    func testYTSMoviesFetch() {
        let expectation = self.expectationWithDescription("YTS Movies Request")
        
        NetworkManager.sharedManager().setServerEndpoints(yts: "http://62.210.81.37/api/v2/", eztv: "https://api-fetch.website/tv/",kat:"")
        NetworkManager.sharedManager().fetchMovies(limit: 20, page: 0, quality: nil, minimumRating: 0, queryTerm: nil, genre: nil, sortBy: "date_added", orderBy: "desc") { movies, error in
            XCTAssertNotNil(movies, "No Movies found")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testYTSMovieDetails() {
        let expectation = self.expectationWithDescription("YTS Movie Details Request")
        
        NetworkManager.sharedManager().setServerEndpoints(yts: "http://62.210.81.37/api/v2/", eztv: "https://api-fetch.website/tv/",kat: "")
        NetworkManager.sharedManager().showDetailsForMovie(movieId: 4778, withImages: true, withCast: true) { movie, error in
            XCTAssertNotNil(movie, "No Movie details")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testYTSMovieSuggestions() {
        let expectation = self.expectationWithDescription("YTS Movie Suggestions Request")
        
        NetworkManager.sharedManager().setServerEndpoints(yts: "http://62.210.81.37/api/v2/", eztv: "https://api-fetch.website/tv/", kat: "")
        NetworkManager.sharedManager().suggestionsForMovie(movieId: 4778) { movies, error in
            XCTAssertNotNil(movies, "No Movie suggestions found")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    // MARK: EZTV
    
    func testEZTVShowPageFetch() {
        let expectation = self.expectationWithDescription("EZTV Show Pages Numbers Request")
        
        NetworkManager.sharedManager().setServerEndpoints(yts: "http://62.210.81.37/api/v2/", eztv: "https://api-fetch.website/tv/", kat: "")
        NetworkManager.sharedManager().fetchShowPageNumbers { pageNumbers, error in
            XCTAssertNotNil(pageNumbers, "No Numbers Found")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testEZTVShowsFetch() {
        let expectation = self.expectationWithDescription("EZTV Shows Request")
        
        NetworkManager.sharedManager().setServerEndpoints(yts: "http://62.210.81.37/api/v2/", eztv: "https://api-fetch.website/tv/", kat: "")
        NetworkManager.sharedManager().fetchShowsForPage(1) { shows, error in
            XCTAssertNotNil(shows, "No shows found")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testEZTVShowDetails() {
        let expectation = self.expectationWithDescription("EZTV SHow Details Request")
        
        NetworkManager.sharedManager().setServerEndpoints(yts: "http://62.210.81.37/api/v2/", eztv: "https://api-fetch.website/tv/",kat: "")
        NetworkManager.sharedManager().fetchShowDetails("tt0944947") { show, error in
            XCTAssertNotNil(show, "No show details")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testEZTVShowSearch() {
        let expectation = self.expectationWithDescription("EZTV Search Request")
        
        NetworkManager.sharedManager().setServerEndpoints(yts: "http://62.210.81.37/api/v2/", eztv: "https://api-fetch.website/tv/",kat: "")
        NetworkManager.sharedManager().fetchShows([1], searchTerm: "arrow") { shows, error in
            XCTAssertNotNil(shows, "No shows details")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testEZTVLatestShows() {
        let expectation = self.expectationWithDescription("EZTV Latest Shows Request")
        
        NetworkManager.sharedManager().setServerEndpoints(yts: "http://62.210.81.37/api/v2/", eztv: "https://api-fetch.website/tv/",kat: "")
        NetworkManager.sharedManager().fetchShows([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) { shows, error in
            XCTAssertNotNil(shows, "No shows details")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(40.0, handler: nil)
    }
    
    // MARK TVDB
    
    func testTVDBSeriesSearch() {
        let expectation = self.expectationWithDescription("TVDB Search Request")
        
        NetworkManager.sharedManager().searchTVDBSeries(295759) { response, error in
            print(response)
            XCTAssertNotNil(response, "No results found")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testTVDBEpisodesSearch() {
        let expectation = self.expectationWithDescription("TVDB Search Request")
        
        NetworkManager.sharedManager().searchTVDBEpisodes(5232057) { response, error in
            print(response)
            XCTAssertNotNil(response, "No results found")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    // MARK: Trakt
    
    func testTraktShowInfo() {
        let expectation = self.expectationWithDescription("Trakt Series Info")
        NetworkManager.sharedManager().fetchTraktSeasonInfoForIMDB("arrow") { response, error in
            XCTAssertNotNil(response, "No results found")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testTraktSeasonEpisodesInfo() {
        let expectation = self.expectationWithDescription("Trakt Season Episode Info")
        NetworkManager.sharedManager().fetchTraktSeasonEpisodesInfoForIMDB("arrow", season: 1) { response, error in
            XCTAssertNotNil(response, "No results found")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testTraktSeasonEpisodeDetailsInfo() {
        let expectation = self.expectationWithDescription("Trakt Season Episodes Info")
        NetworkManager.sharedManager().fetchTraktSeasonEpisodeInfoForIMDB("arrow", season: 1, episode: 2) { response, error in
            XCTAssertNotNil(response, "No results found")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testTraktFanartInfo() {
        let expectation = self.expectationWithDescription("Trakt Fanart")
        NetworkManager.sharedManager().fetchTraktFanartForIMDB("arrow") { response, error in
            XCTAssertNotNil(response, "No results found")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    // MARK: Updates
    
    func testUpdates() {
        let expectation = self.expectationWithDescription("Update Check")
        
        UpdateManager.sharedManager().checkForUpdates(forVersion: "0.2.0") { updateAvailable, name, releaseNotes, error in
            if updateAvailable {
                print(name)
                print(releaseNotes)
            }
            XCTAssertNil(error, "Update check passed")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    // MARK: Other
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
