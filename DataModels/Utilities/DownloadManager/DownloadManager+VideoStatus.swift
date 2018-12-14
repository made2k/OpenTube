
extension DownloadManager {
  
  func isVideoAvailableLocally(_ model: VideoModel) -> Bool {
    return getLocalVideo(for: model) != nil
  }
  
  func getLocalVideo(for videoModel: VideoModel) -> DownloadedVideoPersistedObject? {
    let videoId = videoModel.videoId
    
    return realm.objects(DownloadedVideoPersistedObject.self)
      .filter("videoEntry.videoId == %@", videoId)
      .first
  }
  
  func isDownloadingVideo(for model: VideoModel) -> Bool {
    return currentDownloads[model.videoId] != nil
  }

}
