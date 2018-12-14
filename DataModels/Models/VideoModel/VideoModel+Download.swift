
/*
 Extension for the VideoModel that manages downloads.
 */
extension VideoModel {

  private var manager: DownloadManager {
    return DownloadManager.shared
  }

  private var hasDownloadStarted: Bool {
    return manager.isVideoAvailableLocally(self) || manager.isDownloadingVideo(for: self)
  }

  /**
   This function will manage the download operation based on
   the current download status. If the video has not been
   downloaded aldready, this will trigger a download. If
   the video is downloaded, or is in progress, it'll delete
   or cancel the current download.

   - Parameter quality: The quality of the video to download.
   The quality will be less than or equal to this parameter.
   */
  public func handleDownloadAction(quality: VideoQuality) {
    hasDownloadStarted ? deleteDownload() : download(quality: quality)
  }
  
  private func download(quality: VideoQuality) {
    guard hasDownloadStarted == false else { return }

    let progressBlock: DownloadProgressBlock = { [weak self] progress in
      self?.downloadProgress.accept(progress)
    }

    manager
      .download(model: self, desiredQuality: quality, progress: progressBlock)
      .cauterize()
  }
  
  private func deleteDownload() {
    
    if manager.isDownloadingVideo(for: self) {
      manager.cancelDownload(for: self)
      
    } else if manager.isVideoAvailableLocally(self) {
      manager.deleteDownload(for: self)
    }
    
    downloadProgress.accept(0)
  }
  
}
