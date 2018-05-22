import UIKit
import AsyncDisplayKit
import XCDYouTubeKit
import AVKit
import RealmSwift
import SideMenu
import PromiseKit

class VideoListViewController: ASViewController<ASCollectionNode> {
  
  private(set) var entryList: VideoEntryList
  
  private var player: AVPlayer?
  private weak var playerViewController: AVPlayerViewController?
  private var isPiP = false
  
  private var timeObserver: Any?
  
  init(channelIds: [String]? = nil) {
    entryList = VideoEntryList(with: channelIds)
    
    let flow = UICollectionViewFlowLayout()
    let collection = ASCollectionNode(collectionViewLayout: flow)
    collection.backgroundColor = UIColor(hex: "FBFBFB")
    super.init(node: collection)
    
    flow.minimumLineSpacing = 8
    flow.minimumInteritemSpacing = 12
    
    collection.dataSource = self
    collection.delegate = self
    
    // If we're using the default subscription list, pay attention to any changes
    // and do a hard load to fully refresh data.
    if channelIds == nil {
      
      NotificationCenter.default.addObserver(forName: Notifications.subscriptionListDidChange, object: nil, queue: nil) { [unowned self] _ in
        self.entryList = VideoEntryList(with: nil)
        self.refreshData()
      }
    }
    
    if let channels = channelIds {
      if let channel = channels.first, channels.count == 1 {
        let subscription = try! Realm().objects(SubscribedChannel.self).filter("channelId == %@", channel).first
        title = subscription?.name ?? "Unknown"
      } else {
        title = "Multiple"
      }
    } else {
      title = "Subscriptions"
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidLoad() {
    SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
    
    entryList.reloadEntries().done {
      self.node.reloadData()
    }
    
    setupRefreshControl()
    
    NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidEnterBackground, object: nil, queue: nil) { _ in
      guard !self.isPiP else { return }
      self.playerViewController?.player = nil
    }
    
    NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillEnterForeground, object: nil, queue: nil) { _ in
      guard !self.isPiP else { return }
      self.playerViewController?.player = self.player
    }
    
    let barButton = UIBarButtonItem(title: "Menu", style: .done, target: self, action: #selector(showMenu))
    navigationItem.rightBarButtonItem = barButton
  }
  
  @objc private func showMenu() {
    present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if let observer = timeObserver, !isPiP {
      player?.removeTimeObserver(observer)
      timeObserver = nil
    }
    
    if let selected = node.indexPathsForSelectedItems?.first {
      node.deselectItem(at: selected, animated: animated)
    }
  }
  
  func setupRefreshControl() {
    let refresh = UIRefreshControl()
    refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    node.view.refreshControl = refresh
  }
  
  @objc func refreshData() {
    entryList.reloadEntries().done {
      self.node.reloadData()
      
      }.ensure {
        self.node.view.refreshControl?.endRefreshing()
    }
  }
  
}

extension VideoListViewController: ASCollectionDataSource {
  
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return entryList.videoEntries.count
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
    let entry = entryList.videoEntries[indexPath.row]
    let node = EntryCellNode(entry)
    node.longPressAction = { entry in
      self.longPressAction(for: entry, at: indexPath)
    }
    return node
  }
}

extension VideoListViewController: ASCollectionDelegate {
  
  /*
   If we're in a wide mode, we don't want to show super
   large cells. Figure out the best size to display them
   here to fill a reasonable space.
 */
  func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    
    if collectionNode.bounds.width > 500 {
      let targetCount: Int
      
      switch collectionNode.bounds.width {
      case 500..<675: targetCount = 2
      case 675..<800: targetCount = 3
      default: targetCount = 4
      }
      
      let itemSpacing = (collectionNode.view.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 8
      let maxWidth: CGFloat = (collectionNode.bounds.width / CGFloat(targetCount)) - itemSpacing
      return ASSizeRange(min: CGSize(width: 225, height: 200), max: CGSize(width: maxWidth, height: 250))
      
    } else {
      return ASSizeRange(min: CGSize(width: 225, height: 200), max: CGSize(width: node.bounds.width, height: 350))
    }
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    let entry = entryList.videoEntries[indexPath.row]
    playVideo(with: entry, quality: Settings.defaultStreamQuality)
  }
  
  func playVideo(with entry: EntryObject, quality: VideoQuality) {
    let player = AVPlayerViewController()
    present(player, animated: true, completion: nil)
    
    firstly {
      getAsset(for: entry, quality: quality)
      
      }.done {
        self.playAsset($0, for: entry, with: player)
        
      }.catch { error in
        player.dismiss(animated: true) {
          self.showAlert(title: "Error", message: "There was an error playing the video.")
        }
    }
  }
  
  private func getAsset(for entry: EntryObject, quality: VideoQuality) -> Promise<AVAsset> {
    
    if let downloaded = DownloadManager.shared.localVideo(for: entry) {
      let asset = AVURLAsset(url: downloaded.localUrl)
      return .value(asset)
      
    } else {
      return fetchYouTubeVideo(entry, quality: quality)
    }
  }
  
  private func fetchYouTubeVideo(_ entry: EntryObject, quality: VideoQuality) -> Promise<AVAsset> {
    return Promise { seal in
      
      XCDYouTubeClient.default().getVideoWithIdentifier(entry.videoId) { video, error in
        guard let video = video else { return }
        
        entry.updateDuration(video.duration)
        
        guard let asset = video.assetWithQuality(quality) else { return }
        seal.fulfill(asset)
      }
    }
  }
  
  private func playAsset(_ asset: AVAsset, for entry: EntryObject, with controller: AVPlayerViewController) {
    guard asset.isPlayable else { return }
    
    if let observer = timeObserver, let oldPlayer = self.player {
      oldPlayer.removeTimeObserver(observer)
      timeObserver = nil
    }
    
    let playerItem = AVPlayerItem(asset: asset)
    let player = AVPlayer(playerItem: playerItem)
    
    let startPosition: Double
    if entry.watchProgress >= 0.95 {
      startPosition = 0
    } else {
      startPosition = entry.duration * entry.watchProgress
    }
    player.seek(to: CMTime(seconds: startPosition, preferredTimescale: 1))
    
    self.timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 2, preferredTimescale: 1), queue: nil) { time in
      let percent = time.seconds / entry.duration
      entry.updateProgress(percent)
    }
    
    controller.player = player
    player.play()
    controller.delegate = self
    
    controller.exitsFullScreenWhenPlaybackEnds = true
    
    self.player = player
    self.playerViewController = controller
  }
  
}

extension VideoListViewController: AVPlayerViewControllerDelegate {
  
  func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
    playerViewController.allowsPictureInPicturePlayback = true
    playerViewController.exitsFullScreenWhenPlaybackEnds = true
    present(playerViewController, animated: true) {
      completionHandler(true)
    }
  }
  
  public func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
    isPiP = false
  }
  
  func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
    isPiP = true
  }
  
}
