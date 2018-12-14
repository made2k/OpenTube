
import DataModels
import UIKit

extension VideoDisplayable {

  func videoWasLongPressed(_ model: VideoModel, view: UIView) {
    showActions(for: model, from: view)
  }

  fileprivate func showActions(for entry: VideoModel, from view: UIView) {

    let actionsheet = UIAlertController(title: "Video Options",
                                        message: nil,
                                        preferredStyle: .actionSheet)
    let isWatched = entry.isWatched.value

    actionsheet.addAction(UIAlertAction(title: isWatched ? "Mark Unwatched" : "Mark Watched", style: .default) { _ in
      entry.watchProgress.accept(isWatched ? 0 : 1)
    })
    actionsheet.addAction(UIAlertAction(title: "Play Quality...", style: .default) { _ in
      self.showQualityOptions(for: entry, from: view)
    })

    let isHidden = entry.hidden.value
    actionsheet.addAction(UIAlertAction(title: isHidden ? "Unhide Video" : "Hide Video", style: .default) { _ in
      isHidden ? VideoListModel.shared.unHideVideo(entry) : VideoListModel.shared.hideVideo(entry)
    })

    actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    actionsheet.popoverPresentationController?.sourceRect = view.bounds
    actionsheet.popoverPresentationController?.sourceView = view

    rootViewController.present(actionsheet, animated: true, completion: nil)
  }

  fileprivate func showQualityOptions(for entry: VideoModel, from view: UIView) {

    let actionsheet = UIAlertController(title: "Quality", message: nil, preferredStyle: .actionSheet)
    actionsheet.addAction(UIAlertAction(title: "High (720p)", style: .default) { [weak self] _ in
      self?.playVideo(entry, quality: .high)
    })
    actionsheet.addAction(UIAlertAction(title: "Medium (480p)", style: .default) { [weak self] _ in
      self?.playVideo(entry, quality: .medium)
    })
    actionsheet.addAction(UIAlertAction(title: "Low (360p)", style: .default) { [weak self] _ in
      self?.playVideo(entry, quality: .low)
    })
    actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    actionsheet.popoverPresentationController?.sourceRect = view.bounds
    actionsheet.popoverPresentationController?.sourceView = view

    rootViewController.present(actionsheet, animated: true, completion: nil)
  }

}
