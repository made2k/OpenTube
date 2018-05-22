import UIKit
import Alamofire
import XCDYouTubeKit
import PromiseKit
import RealmSwift

typealias DownloadProgressBlock = (Double) -> Void

class DownloadManager {
  
  static let shared = DownloadManager()
  static let mediaDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  
  private let realm = try! Realm()
  // Cache of currently downloading items. Allows us to cancel requests.
  private var currentDownloads: [String: DownloadRequest] = [:]
  
  private init() {}
  
}

// MARK: - State

extension DownloadManager {
  
  func localVideo(for entry: EntryObject) -> DownloadedEntry? {
    return realm.objects(DownloadedEntry.self).filter("videoEntry.videoId == %@", entry.videoId).first
  }
  
  func isVideoAvailableLocally(_ entry: EntryObject) -> Bool {
    return localVideo(for: entry) != nil
  }
  
  func isDownloading(entry: EntryObject) -> Bool {
    return currentDownloads[entry.videoId] != nil
  }
  
}

// MARK: - Download Tasks

extension DownloadManager {
  
  func download(entry: EntryObject, progress: DownloadProgressBlock?) -> Promise<Void> {
    
    return firstly {
      getYoutubeVideo(entry: entry)
      
    }.map {
      return ($0, entry)
      
    }.then {
      self.download(video: $0, from: $1, progressBlock: progress)
    }
  }
  
  private func download(
    video: XCDYouTubeVideo,
    from entry: EntryObject,
    withQuality: VideoQuality = Settings.defaultDownloadQuality,
    progressBlock: DownloadProgressBlock? = nil) -> Promise<Void> {
    
    
    guard let url = video.urlWithQuality(withQuality) else { return Promise(error: NSError()) }
    let filename = "\(entry.videoId).mp4"
    
    return Promise { seal in
      
      let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
      }
      
      let download = Alamofire.download(url, to: destination)
        .downloadProgress(queue: DispatchQueue.main, closure: { downloadProgress in
          progressBlock?(downloadProgress.fractionCompleted)
        })
        .response { response in
          
          self.currentDownloads[entry.videoId] = nil
          if let error = response.error {
            progressBlock?(0)
            return seal.reject(error)
          }
          
          let download = DownloadedEntry(entry: entry, remoteUrl: url, fileName: filename)
          try! self.realm.write {
            self.realm.add(download)
          }
          
          seal.fulfill(())
      }
      
      self.currentDownloads[entry.videoId] = download
    }
  }
  
  // MARK: Cancel
  
  func cancelDownload(for entry: EntryObject) {
    currentDownloads[entry.videoId]?.cancel()
  }
  
  // MARK: Delete
  
  func deleteDownload(_ download: DownloadedEntry) {
    try? FileManager.default.removeItem(at: download.localUrl)
    try? realm.write {
      realm.delete(download)
    }
  }
  
  func deleteDownload(for entry: EntryObject) {
    guard let download = realm.objects(DownloadedEntry.self).filter("videoEntry.videoId == %@", entry.videoId).first else { return }
    deleteDownload(download)
  }
  
}

// MARK: - Helpers

extension DownloadManager {
  
  private func getYoutubeVideo(entry: EntryObject) -> Promise<XCDYouTubeVideo> {
    
    return Promise { seal in
      
      XCDYouTubeClient.default().getVideoWithIdentifier(entry.videoId) { video, error in
        guard let video = video, error == nil else { return seal.reject(error!) }
        
        entry.updateDuration(video.duration)
        seal.fulfill(video)
      }
    }
  }
  
}
