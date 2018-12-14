
import Alamofire
import PromiseKit
import XCDYouTubeKit

public enum DownloadErrors: Error {
  case notAvailable
}

// MARK: - Download

extension DownloadManager {
  
  /**
   Download a video at the desired quality. If a video URL cannot be found
   This will throw a `DownloadError.notAvailable` error
   */
  func download(model: VideoModel,
                desiredQuality: VideoQuality,
                progress: DownloadProgressBlock?) -> Promise<Void> {

    let q = DispatchQueue.global()
    
    return firstly {
      model.fetchVideoQualities()
      
    }.map(on: q) { values -> URL in
      if let url = values.qualityLessOrEqual(desiredQuality) {
        return url
      }
      throw DownloadErrors.notAvailable
      
    }.then(on: q) { url -> Promise<Void> in
      self.download(url: url, from: model, progressBlock: progress)
    }
  }
  
  private func download(url: URL,
                        from model: VideoModel,
                        progressBlock: DownloadProgressBlock? = nil) -> Promise<Void> {
    
    let filename = "\(model.videoId).mp4"
    
    return Promise { seal in
      
      // Destination configuration
      let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
      }
      
      // Response handler
      let responseBlock: (DefaultDownloadResponse) -> Void = { response in

        self.currentDownloads[model.videoId] = nil
        
        if let error = response.error {
          progressBlock?(0)
          return seal.reject(error)
        }

        // Save the downloaded file to the DB
        let download = DownloadedVideoPersistedObject(model: model,
                                                      remoteUrl: url,
                                                      fileName: filename)
        try? self.realm.write {
          self.realm.add(download)
        }
        
        seal.fulfill(())
      }
      
      // Progress handler
      let progressHandler: (Progress) -> Void = { progress in
        progressBlock?(progress.fractionCompleted)
      }
      
      let downloadRequest = Alamofire.download(url, to: destination)
        .downloadProgress(queue: DispatchQueue.main, closure: progressHandler)
        .response(queue: DispatchQueue.main, completionHandler: responseBlock)

      self.currentDownloads[model.videoId] = downloadRequest
    }
  }
  
}

// MARK: - Cancel

extension DownloadManager {
  
  func cancelDownload(for entry: VideoModel) {
    currentDownloads[entry.videoId]?.cancel()
    currentDownloads[entry.videoId] = nil
  }
  
}

// MARK: - Delete

extension DownloadManager {
  
  func deleteDownload(_ download: DownloadedVideoPersistedObject) {
    try? FileManager.default.removeItem(at: download.localUrl)
    try? realm.write {
      realm.delete(download)
    }
  }
  
  func deleteDownload(for entry: VideoModel) {
    guard let download = realm.objects(DownloadedVideoPersistedObject.self).filter("videoEntry.videoId == %@", entry.videoId).first else { return }
    deleteDownload(download)
  }
  
}
