
import PromiseKit
import XCDYouTubeKit

extension XCDYouTubeClient {
  
  static var `default`: XCDYouTubeClient {
    return XCDYouTubeClient.default()
  }
  
  func getYoutubeVideo(videoModel: VideoModel) -> Promise<XCDYouTubeVideo> {
    
    return Promise<XCDYouTubeVideo> { seal in
      
      getVideoWithIdentifier(videoModel.videoId) { (video, error) in
        
        if let video = video {
          seal.fulfill(video)
          
        } else if let error = error {
          seal.reject(error)
          
        } else {
          let error = NSError(domain: XCDYouTubeVideoErrorDomain,
                              code: XCDYouTubeErrorCode.noStreamAvailable.rawValue,
                              userInfo: nil)
          seal.reject(error)
        }
      }
      
    }
  }
  
}
