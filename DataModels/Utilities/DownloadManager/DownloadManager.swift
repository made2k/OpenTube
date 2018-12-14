
import Alamofire
import XCDYouTubeKit
import RealmSwift

typealias DownloadProgressBlock = (Double) -> Void

final class DownloadManager {
  
  static let shared = DownloadManager()
  
  static let mediaDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  
  internal let realm = try! Realm()
  
  // Cache of currently downloading items. Allows us to cancel requests.
  internal var currentDownloads: [String: DownloadRequest] = [:]
  
  private init() {}
}
