
import AVKit
import DataModels
import UIKit

protocol VideoDisplayable: class {
  var rootViewController: UIViewController { get }
}

extension VideoDisplayable {

  func playVideo(_ model: VideoModel, quality: VideoQuality?) {
    let playerViewController = PlayerViewController(videoModel: model, quality: quality)
    playerViewController.delegate = rootViewController
    playerViewController.onDispose = { [weak self] in
      self?.rootViewController.cleanupPlayerObservers()
    }

    rootViewController.playerViewController = playerViewController
    rootViewController.setupPlayerObservers()

    rootViewController.present(playerViewController, animated: true, completion: nil)
  }

}

extension UIViewController: AVPlayerViewControllerDelegate {

  private struct AssociatedKeys {
    static var isPipActive = "isPipActive"
    static var playerViewController = "playerViewController"
    static var cachedPlayer = "cachedPlayer"
  }

  private var isPip: Bool {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.isPipActive) as? Bool ?? false
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.isPipActive, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  fileprivate var playerViewController: PlayerViewController? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.playerViewController) as? PlayerViewController
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.playerViewController, newValue, .OBJC_ASSOCIATION_ASSIGN)
    }
  }

  fileprivate var cachedPlayer: AVPlayer? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.cachedPlayer) as? AVPlayer
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.cachedPlayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  public func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
    isPip = true
    if let cachedPlayer = cachedPlayer, playerViewController.player == nil {
      playerViewController.player = cachedPlayer
    }
  }

  public func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
    isPip = false
  }

  public func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
    playerViewController.allowsPictureInPicturePlayback = true
    playerViewController.exitsFullScreenWhenPlaybackEnds = true

    present(playerViewController, animated: true) {
      completionHandler(true)
    }
  }

  fileprivate func setupPlayerObservers() {

    NotificationCenter.default.addObserver(self, selector: #selector(enteringBackground), name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(enteringForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

  }

  fileprivate func cleanupPlayerObservers() {
    playerViewController = nil
    cachedPlayer = nil

    NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
  }

  @objc private func enteringForeground() {

    if let player = cachedPlayer {
      playerViewController?.player = player
    }
    self.cachedPlayer = nil

  }

  @objc private func enteringBackground() {

    guard let playerController = playerViewController else { return }
    guard isPip == false else { return }

    cachedPlayer = playerController.player
    playerController.player = nil
  }

}

