
import Foundation
import RxCocoa
import RxSwift

/**
 This model is responsible for figuring out the display
 of the "Up Next" section of the app.
 */
public final class UpNextModel: NSObject {

  public static let shared = UpNextModel()

  public let videoList = BehaviorRelay<[VideoModel]>(value: [])

  private let parseScheduler = SerialDispatchQueueScheduler(qos: .default)
  private let disposeBag = DisposeBag()
  private var videoTrackerDisposeBag = DisposeBag()

  private override init() {
    super.init()
    setupBindings()
  }

  private func setupBindings() {

    // When our whole video list changes, we have to
    // reload our mappings into the up next.
    VideoListModel.shared.videoList.asObservable()
      .distinctUntilChanged()
      .observeOn(parseScheduler)
      .map { [unowned self] videos -> [VideoModel] in
        return self.mapVideoList(videos)
      }.bind(to: videoList)
      .disposed(by: disposeBag)

    // When the videos change, setup the new observer
    // to watch each of the videos
    VideoListModel.shared.videoList.asObservable()
      .subscribe(onNext: { [unowned self] _ in
        self.reloadExistingVideoTracker()
      }).disposed(by: disposeBag)

  }

  private func reloadExistingVideoTracker() {
    videoTrackerDisposeBag = DisposeBag()

    let allVideos = VideoListModel.shared.videoList.value

    for video in allVideos {

      // Here we're observing the state of watched and if a video changed to in progress
      // so that we can reload our up next list. Up next is based on watched and progress.
      Observable.combineLatest(video.inProgress.asObservable(),
                               video.isWatched.asObservable()) { ($0, $1) }
        .distinctUntilChanged { (first, second) -> Bool in
          return first.0 == second.0 && first.1 == second.1
        }
        .skip(1)
        .observeOn(parseScheduler)
        .map { [unowned self] _ -> [VideoModel] in
          let allVideos = VideoListModel.shared.videoList.value
          return self.mapVideoList(allVideos)

        }.subscribe(onNext: { [unowned self] in
          self.videoList.accept($0)

        }).disposed(by: videoTrackerDisposeBag)

    }
  }

  /**
   With this function we're taking a list of videos and determining
   what videos will be displayed in the up next section.

   Watched videos will not be displayed.

   A newer video has priority over an older video.

   A video currently in progress has the highest priority.

   Only one video per channel will appear.
   */
  private func mapVideoList(_ videos: [VideoModel]) -> [VideoModel] {

    let unwatchedVideos = videos
      .filter { $0.isWatched.value == false }
      .filter { $0.channel != nil }

    var fetchedChannels: [ChannelModel: VideoModel] = [:]

    for video in unwatchedVideos {

      let channel = video.channel.unsafelyUnwrapped

      // If we've already got a video for this channel, only replace it if
      // the current watch progress if further along
      if let currentVideo = fetchedChannels[channel] {
        if video.watchProgress.value > currentVideo.watchProgress.value {
          fetchedChannels[channel] = video
        }

      } else {
        // No video for this channel, takes priority
        fetchedChannels[channel] = video
      }
    }

    let videoValues: [VideoModel] = Array(fetchedChannels.values)
    return videoValues.sorted(by: { $0.publishDate > $1.publishDate })
  }

}
