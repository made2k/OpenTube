import UIKit
import AsyncDisplayKit
import RealmSwift
import AVKit

class DownloadListViewController: ASViewController<ASTableNode> {
  
  private var downloads: [DownloadedEntry] = []
  
  init() {
    let table = ASTableNode(style: .plain)
    super.init(node: table)
    table.dataSource = self
    table.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let realm = try! Realm()
    downloads = Array(realm.objects(DownloadedEntry.self))
    node.reloadData()
  }
  
  private func playAsset(_ asset: AVAsset, for entry: EntryObject) {
    guard asset.isPlayable else { return }
    
    let controller = AVPlayerViewController()
    let playerItem = AVPlayerItem(asset: asset)
    let player = AVPlayer(playerItem: playerItem)
    
    let startPosition = entry.duration * entry.watchProgress
    player.seek(to: CMTime(seconds: startPosition, preferredTimescale: 1))
    
    player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 2, preferredTimescale: 1), queue: nil) { time in
      let percent = time.seconds / entry.duration
      entry.updateProgress(percent)
    }
    
    controller.player = player
    self.present(controller, animated: true, completion: { player.play() })
  }
}

extension DownloadListViewController: ASTableDataSource {
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return downloads.count
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    let entry = downloads[indexPath.row]
    return DownloadCellNode(downloadEntry: entry)
  }
  
}

extension DownloadListViewController: ASTableDelegate {
  
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let download = downloads[indexPath.row]
    
    let asset = AVURLAsset(url: download.localUrl)
    playAsset(asset, for: download.videoEntry)
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .delete
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    let download = downloads[indexPath.row]
    
    DownloadManager.shared.deleteDownload(download)
    
    downloads.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }
}
