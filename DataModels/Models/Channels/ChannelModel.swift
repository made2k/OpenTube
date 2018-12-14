
import Network
import PromiseKit
import RealmSwift
import RxCocoa
import RxSwift
import SwiftyXML

/// Model representing a YouTube channel or user
/// that uploads videos.
public final class ChannelModel: NSObject {

  public let channelId: String
  public let channelName: String
  public let channelThumbnail: URL

  public let videos: BehaviorRelay<[VideoModel]>
  public let notificationsEnabled: BehaviorRelay<Bool>

  private let realm = try! Realm()

  private var persisted: ChannelPersistedObject!
  private var needsPersistedSave: Bool = false
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  init(channelId: String, channelName: String, thumbnail: URL) {

    self.channelId = channelId
    self.channelName = channelName
    self.channelThumbnail = thumbnail

    self.needsPersistedSave = true

    videos = BehaviorRelay<[VideoModel]>(value: [])
    notificationsEnabled = BehaviorRelay<Bool>(value: false)

    super.init()

    persisted = ChannelPersistedObject(model: self)

    setupBindings()
  }

  init(persisted: ChannelPersistedObject) {
    channelId = persisted.channelId
    channelName = persisted.channelName
    channelThumbnail = URL(string: persisted.thumbnailURLString).unsafelyUnwrapped

    let persistedVideos = realm.objects(VideoPersistedObject.self)
      .filter("channelId == %@ AND hidden == %@", channelId, false)
      .sorted(byKeyPath: "publishDate")
      .reversed()
      .map { VideoModel(persisted: $0) }
    videos = BehaviorRelay<[VideoModel]>(value: Array(persistedVideos))

    notificationsEnabled = BehaviorRelay<Bool>(value: persisted.notificationsEnabled)

    self.persisted = persisted

    super.init()

    setupBindings()
  }

  // MARK: - Bindings

  private func setupBindings() {

    notificationsEnabled.asObservable()
      .distinctUntilChanged()
      .subscribe(onNext: { [unowned self] enabled in
        self.persisted.updateNotifications(enabled)
      }).disposed(by: disposeBag)

  }

  // MARK: - Persisted

  func savePersisted() {
    guard needsPersistedSave else { return }

    do {
      try persisted.saveObject()

    } catch {
      print("error saving to DB")
    }
  }

  func deletePersisted() throws {
    try persisted.removeObject()

    for video in videos.value {
      try video.deletePersisted()
    }
  }

  // MARK: - New videos

  /**
   Fetch and save new videos for this channel.

   - Returns: A promise that resolves into an array
   of the new videos that were fetched.
   */
  public func getNewVideos() -> Promise<[VideoModel]> {
    let q = DispatchQueue.global()
    let realmQ = DispatchQueue.main

    return firstly {
      YouTubeAPI.shared.fetchXMLEntries(for: channelId)

    }.mapValues(on: realmQ) { xml -> VideoModel? in
      VideoModel(xml: xml, channelId: self.channelId)

    }.map(on: q) { optionalValues -> [VideoModel] in
      return optionalValues.compactMap { $0 }

    }.filterValues(on: realmQ) { videoModel in
      self.realm.objects(VideoPersistedObject.self).filter("videoId == %@", videoModel.videoId).isEmpty

    }.get(on: realmQ) { newVideos in
      newVideos.forEach { $0.savePersistedToDatabase() }

    }.get(on: q) { newVideos in
      newVideos.forEach { $0.fetchVideoQualities().cauterize() }

    }.get(on: q) { newVideos in
      let oldVideos = self.videos.value
      let newVideoList = newVideos + oldVideos
      self.videos.accept(newVideoList)
    }

  }

}
