
import AVKit
import DataModels
import PromiseKit
import UIKit

final class PlayerViewController: AVPlayerViewController {

  private var model: VideoModel!
  private var desiredQuality: VideoQuality?

  var onDispose: (() -> Void)?

  override var player: AVPlayer? {
    didSet {

      if let timeObserver = timeObserver, let oldValue = oldValue {
        oldValue.removeTimeObserver(timeObserver)
      }

      if let player = player {
        bindToPlayer(player)
      }
    }
  }

  private var timeObserver: Any?

  // MARK: - Initialization

  convenience init(videoModel: VideoModel, quality: VideoQuality?) {
    self.init()

    self.model = videoModel
    self.desiredQuality = quality

    self.exitsFullScreenWhenPlaybackEnds = true
    self.allowsPictureInPicturePlayback = true

    loadVideo()
  }

  deinit {
    if let timeObserver = timeObserver {
      player?.removeTimeObserver(timeObserver)
    }
    onDispose?()
  }

  // MARK: - Video Loading

  private func loadVideo() {

    let quality = desiredQuality ?? AppSettings.defaultStreamQuality
    let startTime = startPosition(for: model)

    firstly {
      model.fetchVideoURL(for: quality)

    }.then { url -> Guarantee<Void> in
      self.setupPlayer(with: url, andSeekTo: startTime)

    }.done {
      self.player?.play()

    }.done {
      self.model.lastWatchedDate.accept(Date())

    }.catch { _ in
      self.showFailedError()
    }
  }

  // MARK: - Player Setup

  private func setupPlayer(with url: URL, andSeekTo startTime: TimeInterval) -> Guarantee<Void> {
    let player = AVPlayer(url: url)
    player.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    self.player = player
    return player.seek(to: startTime)
  }

  private func bindToPlayer(_ player: AVPlayer) {

    let interval = CMTime(seconds: 1, preferredTimescale: 1)
    let q = DispatchQueue.global()

    timeObserver = player
      .addPeriodicTimeObserver(forInterval: interval, queue: q) { [unowned self] time in

        guard let duration = self.model.duration.value else { return }
        guard duration > 0 else { return }

        let percent = time.seconds / duration
        self.model.watchProgress.accept(percent)
    }

  }

  // MARK: - Helpers

  private func startPosition(for model: VideoModel) -> TimeInterval {
    if model.isWatched.value {
      return 0
    } else {
      return (model.duration.value ?? 0) * model.watchProgress.value
    }
  }

  private func showFailedError() {
    showAlert(title: "Error playing content", message: "Try restarting the app or checking your network.")
  }

  // MARK: - KVO

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

    if let item = object as? AVPlayerItem, keyPath == "status" {

      switch item.status {
      case .failed:
        showFailedError()
        item.removeObserver(self, forKeyPath: "status")
      case .readyToPlay:
        item.removeObserver(self, forKeyPath: "status")
      default:
        break
      }

    }
  }

}
