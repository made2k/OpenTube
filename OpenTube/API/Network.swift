import UIKit
import Alamofire
import SwiftyXML
import PromiseKit
import RealmSwift

class Network: NSObject {
  
  static let shared = Network()
  
  private let urlPrefix = "https://www.youtube.com/feeds/videos.xml?channel_id="
  
  private override init() { }
  
  func getNewEntries(_ channelIds: [String]) -> Promise<[VideoEntry]> {
    
    let promises = channelIds.map { fetchNewEntries($0) }
    
    return when(fulfilled: promises)
      .flatMapValues{ $0 }
      .map { entries -> [VideoEntry] in
        return entries.sorted(by: { (first, second) -> Bool in
          return first.publishDate < second.publishDate
        })
      }
  }
  
  private func fetchNewEntries(_ channelId: String) -> Promise<[VideoEntry]> {
    
    return Promise { seal in
      
      let url = "\(urlPrefix)\(channelId)"
      
      Alamofire.request(url).responseData { response in
        
        guard let data = response.value else { return }
        guard let xml = XML(data: data) else { return }
        
        var entries: [VideoEntry] = []
        
        for entry in xml.children.filter({ $0.name == "entry" }) {
          if let entry = VideoEntry(xml: entry, channelId: channelId) {
            entries.append(entry)
          }
        }
        
        if let author = entries.first?.author {
          let realm = try? Realm()
          let subscribed = realm?.objects(SubscribedChannel.self).filter("channelId = %@", channelId).first
          subscribed?.updateChannelName(author.name)
        }
        
        seal.fulfill(entries)
      }
    }
  }
}
