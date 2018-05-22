import UIKit
import SwiftyXML

/// Representation of a Video Entry from the RSS feed.
class VideoEntry: NSObject {
  
  let videoId: String
  let title: String
  let publishDate: Date
  let thumbnailUrl: URL
  let videoDescription: String
  
  let author: ChannelAuthor
  
  let channelId: String
  
  init?(xml: XML, channelId: String) {
    guard let author = ChannelAuthor(xml: xml) else { return nil }
    
    self.channelId = channelId
    
    self.author = author
    videoId = xml["yt:videoId"].stringValue
    title = xml["title"].stringValue
    thumbnailUrl = URL(string: xml["media:group"]["media:thumbnail"]["@url"].stringValue)!
    videoDescription = xml["media:group"]["media:description"].stringValue
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-LL-dd'T'HH:mm:ssxxxx"
    publishDate = dateFormatter.date(from: xml["published"].stringValue) ?? Date()
  }
}
