import Foundation
import Alamofire

public class UpdateManager {

    public class func sharedManager() -> UpdateManager {
        struct Struct {
            static let Instance = UpdateManager()
        }

        return Struct.Instance
    }

    public func checkForUpdates(forVersion version: String, completion: ((updateAvailable: Bool, name: String?, releaseNotes: String?, error: NSError?) -> Void)?) {
        Alamofire.request(.GET, "https://api.github.com/repos/PopcornTimeTV/PopcornTimeTV/releases")
        .responseJSON { response in
            if let response = response.result.value as? [[String : AnyObject]] {
                if let latest = response.first {
                    if let latestVersion = latest["tag_name"] as? String, let name = latest["name"] as? String, let releaseNotes = latest["body"] as? String {
                        if latestVersion != version {
                            completion?(updateAvailable: true, name: name, releaseNotes: releaseNotes, error: nil)
                        } else {
                            completion?(updateAvailable: false, name: nil, releaseNotes: nil, error: nil)
                        }
                    }
                }
            } else {
                completion?(updateAvailable: false, name: nil, releaseNotes: nil, error: response.result.error)
            }
        }
    }

}
