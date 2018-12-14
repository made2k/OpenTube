
import Foundation
import RealmSwift

/**
 A Realm object representing a Channel.
 */
final class ChannelPersistedObject: Object {
  
  @objc dynamic var channelName: String = ""
  @objc dynamic var channelId: String = ""
  @objc dynamic var thumbnailURLString: String = ""

  @objc dynamic var notificationsEnabled: Bool = false

  convenience init(model: ChannelModel) {
    self.init()

    channelName = model.channelName
    channelId = model.channelId
    thumbnailURLString = model.channelThumbnail.absoluteString

  }

  func updateNotifications(_ enabled: Bool) {
    try? safeRealm?.write {
      self.notificationsEnabled = enabled
    }
  }

}
