
import Foundation
import RealmSwift

final class DownloadedVideoPersistedObject: Object {

  @objc dynamic var remoteUrlString: String = ""
  @objc dynamic var fileName: String = ""

  @objc dynamic var videoEntry: VideoPersistedObject!

  var remoteUrl: URL {
    return URL(string: remoteUrlString).unsafelyUnwrapped
  }
  var localUrl: URL {
    return DownloadManager.mediaDirectory.appendingPathComponent(fileName)
  }

  convenience init(model: VideoModel, remoteUrl: URL, fileName: String) {
    self.init()

    self.remoteUrlString = remoteUrl.absoluteString
    self.fileName = fileName
    self.videoEntry = model.persisted
  }

}
