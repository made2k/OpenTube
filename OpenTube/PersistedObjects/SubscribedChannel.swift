import UIKit
import Alamofire
import RealmSwift

class SubscribedChannel: Object {
  
  class func create(with channelId: String, notify: Bool = true) {
    let realm = try! Realm()
    guard realm.objects(SubscribedChannel.self).filter("channelId == %@", channelId).isEmpty else { return }
    
    let newSubscription = SubscribedChannel(channelId: channelId)
    try? realm.write {
      realm.add(newSubscription)
    }
    
    if notify {
      NotificationCenter.default.post(name: Notifications.subscriptionListDidChange, object: nil)
    }
  }
  
  @objc dynamic var channelId: String = ""
  
  /*
   A subscribed channel only requires a channel ID.
   Because of this, we get limited information. The name
   of the channel and the thumbnail url need to be grabbed
   from YouTube itself.
   */
  @objc dynamic var name: String? = nil
  @objc dynamic var channelThumbnailString: String? = nil
  @objc dynamic var notificationsEnabled: Bool = false
  
  private convenience init(channelId: String) {
    self.init()
    self.channelId = channelId
    
    fetchData()
  }
  
  func updateChannelName(_ name: String) {
    guard name != self.name else { return }
    
    try? realm?.write {
      self.name = name
    }
  }
  
  /// Fetch the HTML from YouTube for the channel, then parse it
  private func fetchData() {
    guard let url = URL(string: "https://www.youtube.com/channel/\(channelId)") else { return }
    Alamofire.request(url).responseString(completionHandler: parseResponse)
  }
  
  /// Attempt to extract the thumbnail string for the channel.
  private func parseResponse(_ response: DataResponse<String>) {
    guard let html = response.value else { return }
    
    try? realm?.write {
      channelThumbnailString = html.substring(after: "<img class=\"appbar-nav-avatar\" src=\"", before: "\"")
    }
    
  }
}
