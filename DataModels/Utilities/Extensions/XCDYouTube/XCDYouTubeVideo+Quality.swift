import AVKit
import XCDYouTubeKit

extension XCDYouTubeVideo {
  
  func urlWithQuality(_ quality: VideoQuality) -> URL? {
    switch  quality {
    case .high:
      return highUrl
    case .medium:
      return mediumUrl
    case .low:
      return lowUrl
    }
  }

  private var highUrl: URL? {
    return streamURLs[VideoQuality.high.videoKey] ?? mediumUrl
  }
  
  private var mediumUrl: URL? {
    return streamURLs[VideoQuality.medium.videoKey] ?? lowUrl
  }
  
  private var lowUrl: URL? {
    return streamURLs[VideoQuality.low.videoKey]
  }
}
