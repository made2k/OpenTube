
import Foundation
import PromiseKit
import RealmSwift
import RxCocoa
import RxSwift

/**
 This model contains our videos fetched from our subscriptions.
 The `videoList` property will contains videos meant to be
 displayed (i.e. videos not hidden).
 */
public final class VideoListModel: NSObject {

  public static let shared = VideoListModel()

  /// This function does nothing, but allows the shared object
  /// to be created upon app launch.
  public func configure() {}

  public let videoList = BehaviorRelay<[VideoModel]>(value: [])

  private let realm = try! Realm()
  private let disposeBag = DisposeBag()

  private override init() {
    super.init()

    let savedVideos = getPersistedVideos()
    videoList.accept(savedVideos)

    setupBindings()
  }

  // MARK: - Bindings

  private func setupBindings() {

    // When our list of subscriptions changes, we need
    // to reload videos
    ChannelListModel.shared.subscriptions.asObservable()
      .skip(1)
      .observeOn(SerialDispatchQueueScheduler(qos: .default))
      .subscribe(onNext: { [unowned self] _ in
        self.subscribedChannelsChanged()
      }).disposed(by: disposeBag)

  }

  private func subscribedChannelsChanged() {
    let q = DispatchQueue.global()
    let savedVideos = getPersistedVideos()

    firstly {
      self.fetchNewVideos()

    }.map(on: q) { newVideos -> [VideoModel] in
      return savedVideos + newVideos

    }.map(on: q) { allVideos -> [VideoModel] in
      return allVideos.sorted(by: { $0.publishDate > $1.publishDate })

    }.done(on: q) { videos in
      self.videoList.accept(videos)

    }.cauterize()

  }

  // MARK: - Video Fetching

  /**
   For each of our subscribed channels, fetch the new videos
   from that channel. Then save the videos to the persistend
   database for use later.
   */
  public func fetchAndSaveNewVideos() -> Promise<[VideoModel]> {
    let q = DispatchQueue.global()

    // New videos to return
    var resolvedVideos: [VideoModel] = []

    return firstly {
      fetchNewVideos()

    }.get(on: q) { newVideos in
      resolvedVideos = newVideos

    }.map(on: q) { newVideos -> [VideoModel] in
      return self.videoList.value + newVideos

    }.map(on: q) { videos -> [VideoModel] in
      return videos.sorted(by: { $0.publishDate > $1.publishDate })

    }.get(on: q) {
      self.videoList.accept($0)

    }.map(on: q) { _ -> [VideoModel] in
      return resolvedVideos
    }
  }

  private func fetchNewVideos() -> Promise<[VideoModel]> {
    let q = DispatchQueue.global()
    let channels = ChannelListModel.shared.subscriptions.value
    let promises = channels.map { $0.getNewVideos() }

    return firstly {
      when(fulfilled: promises).flatMapValues { $0 }

    }.map(on: q) { newVideos -> [VideoModel] in
      return newVideos.sorted(by: { $0.publishDate > $1.publishDate })
    }
  }

  // MARK: - Video Accessors

  func getPersistedVideos() -> [VideoModel] {
    return ChannelListModel.shared.subscriptions.value
      .map { $0.videos.value }
      .flatMap { $0 }
      .sorted(by: { $0.publishDate > $1.publishDate })
  }

  public func getDownloadedVideos() -> [VideoModel] {
    let downloadedVideos = realm.objects(DownloadedVideoPersistedObject.self)
      .map { $0.videoEntry }
      .compactMap { $0 }
      .map { [unowned self] video -> VideoModel in
        if let existing = self.videoList.value.first(where: { $0.videoId == video.videoId }) {
          return existing
        }
        return VideoModel(persisted: video)
    }

    return Array(downloadedVideos)
  }

  public func getHiddenVideos() -> [VideoModel] {
    let hiddenVideos = realm.objects(VideoPersistedObject.self)
      .filter("hidden == %@", true)
      .map { [unowned self] video -> VideoModel in
        if let existing = self.videoList.value.first(where: { $0.videoId == video.videoId }) {
          return existing
        }
        return VideoModel(persisted: video)
    }

    return Array(hiddenVideos)
  }

  // MARK: - List Actions

  /**
   Hides a video and removes it from the list of videos to display.

   - Parameter model: The video model to hide.
   */
  public func hideVideo(_ model: VideoModel) {
    guard model.hidden.value == false else { return }
    model.hidden.accept(true)
    videoList.accept(videoList.value.filter { $0 !== model })
  }

  /**
   Unhides a video and adds it to the list of videos to display.

   - Parameter model: The video model to unhide.
   */
  public func unHideVideo(_ model: VideoModel) {
    guard model.hidden.value == true else { return }
    model.hidden.accept(false)
    videoList.accept(getPersistedVideos())
  }

}
