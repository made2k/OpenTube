
import PromiseKit
import RxCocoa
import RxOptional
import RxSwift
import SwiftyXML
import Utilities
import XCDYouTubeKit

public enum VideoError: Error {
  case videoNotFound
}

/**
 This model represents a video from YouTube. It will
 keep track of the persisted data we keep in the app.
 */
public final class VideoModel: NSObject {
  
  // Video Properties
  let videoId: String
  public let title: String
  public let publishDate: Date
  public let thumbnailUrl: URL
  public let videoDescription: String

  // Channel
  let channelId: String?
  public var channel: ChannelModel? {
    guard let channelId = self.channelId else { return nil }
    let channelList = ChannelListModel.shared.subscriptions.value
    return channelList.first(where: { $0.channelId == channelId })
  }
  
  // Variable
  public let duration = BehaviorRelay<TimeInterval?>(value: nil)
  public let watchProgress = BehaviorRelay<Double>(value: 0)
  public let hidden = BehaviorRelay<Bool>(value: false)
  public let isWatched = BehaviorRelay<Bool>(value: false)
  public let lastWatchedDate = BehaviorRelay<Date?>(value: nil)
  public let inProgress = BehaviorRelay<Bool>(value: false)
  public let downloadProgress = BehaviorRelay<Double>(value: 0)
  public let durationDescription = BehaviorRelay<String?>(value: nil)

  public var detailDescription: String {
    let author = channel?.channelName
    let ageString = publishDate.ageDescription
    return [author, ageString].compactMap { $0 }.joined(separator: " • ")
  }
  
  // Video File Information
  var videoQualities: [VideoQuality: URL] = [:]
  private var downloadedUrl: URL? {
    return DownloadManager.shared.getLocalVideo(for: self)?.localUrl
  }

  // Persist
  var needsToSaveObject = false
  private(set) var persisted: VideoPersistedObject!

  // Bindings
  let disposeBag = DisposeBag()
  
  // MARK: - Initialization
  
  init?(xml: XML, channelId: String) {
    guard let videoId = xml["yt:videoId"].string else { return nil }
    guard let title = xml["title"].string else { return nil }
    guard let thumbnailString = xml["media:group"]["media:thumbnail"]["@url"].string else { return nil }
    guard let thumbnailUrl = URL(string: thumbnailString) else { return nil }

    self.channelId = channelId
    self.videoId = videoId
    self.title = title
    self.thumbnailUrl = thumbnailUrl

    self.videoDescription = xml["media:group"]["media:description"].stringValue
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-LL-dd'T'HH:mm:ssxxxx"
    self.publishDate = dateFormatter.date(from: xml["published"].stringValue) ?? Date()
    
    super.init()
    
    self.persisted = VideoPersistedObject(videoModel: self)
    self.needsToSaveObject = true

    setupBindings()
  }
  
  init(persisted: VideoPersistedObject) {
    self.videoId = persisted.videoId
    self.title = persisted.title
    self.publishDate = persisted.publishDate
    self.thumbnailUrl = URL(string: persisted.thumbnailString)!
    self.videoDescription = persisted.videoDescription
    
    self.channelId = persisted.channelId
    
    self.duration.accept(persisted.duration == 0 ? nil : persisted.duration)
    self.watchProgress.accept(persisted.watchProgress)
    self.lastWatchedDate.accept(persisted.lastWatchDate)
    self.hidden.accept(persisted.hidden)
    
    self.persisted = persisted
    
    super.init()
    
    let isDownloaded = DownloadManager.shared.isVideoAvailableLocally(self)
    downloadProgress.accept(isDownloaded ? 1 : 0)
    
    setupBindings()
  }

  /**
   Given a playable video, this initializer will create a model
   for play. This currently should not persist to the database
   since there is no parsable channel ID from the youtube video.

   - Parameter video: A video to contain in the model object.
   */
  public init(video: XCDYouTubeVideo) {
    self.videoId = video.identifier
    self.title = video.title
    self.publishDate = Date()
    self.thumbnailUrl = video.thumbnailURL.unsafelyUnwrapped
    self.videoDescription = ""
    self.channelId = nil
    
    super.init()
    
    self.persisted = VideoPersistedObject(videoModel: self)
    // Disallow this to be saved
    needsToSaveObject = false
    setupBindings()
  }

  /**
   Get a playable video URL based on the provided quality. If
   this video has been downloaded, the local URL of the download
   will be returned.

   - Parameter quality: The quality cieling to fetch. A URL with quality
   higher than this parameter will not be returned.
   - Returns: A promise with a playable URL for a video.
   */
  public func fetchVideoURL(for quality: VideoQuality) -> Promise<URL> {

    // If we have a downloaded url, return that
    if let downloaded = downloadedUrl { return .value(downloaded) }

    // If we already have a URL for this file, return that
    if let url = videoQualities.qualityLessOrEqual(quality) { return .value(url) }

    let q = DispatchQueue.global()

    return firstly {
      fetchVideoQualities(force: true)

    }.map(on: q) { qualities -> URL in
      if let url = qualities.qualityLessOrEqual(quality) {
        return url
      }
      throw VideoError.videoNotFound
    }
  }

  /// Save this model to the database.
  func savePersistedToDatabase() {
    guard let persisted = persisted else { return }
    guard needsToSaveObject else { return }

    do {
      try persisted.saveObject()
      needsToSaveObject = false

    } catch {
      needsToSaveObject = true
    }
  }

  /// Remove the video from our local database.
  func deletePersisted() throws {
    try persisted.removeObject()
  }
  
}
