import UIKit
import AsyncDisplayKit

extension VideoListViewController {
  
  func longPressAction(for entry: EntryObject, at indexPath: IndexPath) {
    let entry = entryList.videoEntries[indexPath.row]
    let node = self.node.nodeForItem(at: indexPath)!
    
    let actionsheet = UIAlertController(title: "Video Options", message: nil, preferredStyle: .actionSheet)
    
    let isWatched = entry.watchProgress >= 0.95
    actionsheet.addAction(UIAlertAction(title: isWatched ? "Mark Unwatched" : "Mark Watched", style: .default) { _ in
      entry.updateProgress(isWatched ? 0 : 1)
    })
    actionsheet.addAction(UIAlertAction(title: "Play Quality...", style: .default) { _ in
      self.showQualityOptions(for: entry)
    })
    actionsheet.addAction(UIAlertAction(title: "Hide Video", style: .default) { _ in
      self.entryList.hideVideo(at: indexPath.row)
      // self.node.deleteItems(at: [indexPath]) Index paths are not updated with this
      self.node.reloadData()
    })
    actionsheet.addAction(UIAlertAction(title: "Delete Video", style: .destructive) { _ in
      self.entryList.deleteVideo(at: indexPath.row)
      self.node.reloadData()
    })
    
    actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    actionsheet.popoverPresentationController?.sourceRect = node.bounds
    actionsheet.popoverPresentationController?.sourceView = node.view
    
    present(actionsheet, animated: true, completion: nil)
  }
  
  private func showQualityOptions(for entry: EntryObject) {
    let actionsheet = UIAlertController(title: "Quality", message: nil, preferredStyle: .actionSheet)
    actionsheet.addAction(UIAlertAction(title: "High (720p)", style: .default) { _ in
      self.playVideo(with: entry, quality: .high)
    })
    actionsheet.addAction(UIAlertAction(title: "Medium (480p)", style: .default) { _ in
      self.playVideo(with: entry, quality: .medium)
    })
    actionsheet.addAction(UIAlertAction(title: "Low (360p)", style: .default) { _ in
      self.playVideo(with: entry, quality: .small)
    })
    actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(actionsheet, animated: true, completion: nil)
  }
}
