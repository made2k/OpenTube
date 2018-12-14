
import Foundation
import RealmSwift

/**
 A Realm object that represents a Video Entry
 from the YouTube RSS feed.
 */
final class VideoPersistedObject: Object {

  @objc dynamic var channelId: String?
  
  // Video Properties
  @objc dynamic var videoId: String = ""
  @objc dynamic var title: String = ""
  @objc dynamic var publishDate: Date = Date()
  @objc dynamic var thumbnailString: String = ""
  @objc dynamic var videoDescription: String = ""

  // App Set Properties
  @objc dynamic var duration: Double = 0
  @objc dynamic var watchProgress: Double = 0
  @objc dynamic var lastWatchDate: Date?
  @objc dynamic var hidden: Bool = false

  convenience init(videoModel: VideoModel) {
    self.init()
    
    videoId = videoModel.videoId
    title = videoModel.title
    publishDate = videoModel.publishDate
    thumbnailString = videoModel.thumbnailUrl.absoluteString
    videoDescription = videoModel.videoDescription
    channelId = videoModel.channelId
  }
  
  func updateDuration(_ duration: Double) {
    try? safeRealm?.write {
      self.duration = duration
    }
  }
  
  func updateProgress(_ progressPercent: Double) {
    try? safeRealm?.write {
      self.watchProgress = progressPercent
    }
  }
  
  func updateHidden(_ hidden: Bool) {
    try? safeRealm?.write {
      self.hidden = hidden
    }
  }

  func updateLastWatched(_ date: Date?) {
    try? safeRealm?.write {
      self.lastWatchDate = date
    }
  }
  
}
