
import Alamofire
import PromiseKit
import SwiftyXML

/**
 This class is used to interface with YouTube's site.
 */
final class YouTubeAPI: NSObject {

  private let channelFetchPrefix = "https://www.youtube.com/feeds/videos.xml?channel_id="

  static let shared = YouTubeAPI()
  private override init() { }

  /**
   Given a channel ID, this function will hit YouTube's RSS
   Service to retrieve XML representation of the channels videos

   - Parameter channelId: The id of the channel to get xml entries for
   - Returns: A promise that will resolve into an array of XML video entries
   */
  func fetchXMLEntries(for channelId: String) -> Promise<[XML]> {
    let q = DispatchQueue.global()

    return firstly {
      fetchVideosRequest(urlString: channelFetchPrefix + channelId)

    }.map(on: q) { data -> XML in
      return XML(data: data)

    }.map(on: q) { topLevelXML -> [XML] in
      return topLevelXML.children.filter { $0.name == "entry" }
    }
  }

  private func fetchVideosRequest(urlString: String) -> Promise<Data> {
    return Alamofire.request(urlString).responseData().map { $0.data }
  }

}
