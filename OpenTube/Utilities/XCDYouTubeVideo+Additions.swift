import AVKit
import XCDYouTubeKit

extension XCDYouTubeVideo {
  
  func urlWithQuality(_ quality: VideoQuality) -> URL? {
    switch  quality {
    case .high:
      return highUrl
    case .medium:
      return mediumUrl
    case .small:
      return lowUrl
    }
  }
  
  func assetWithQuality(_ quality: VideoQuality) -> AVAsset? {
    switch  quality {
    case .high:
      return high
    case .medium:
      return medium
    case .small:
      return low
    }
  }
  
  var high: AVAsset? {
    if let video = highUrl {
      return AVURLAsset(url: video)
    }
    return medium
  }
  
  var medium: AVAsset? {
    if let video = mediumUrl {
      return AVURLAsset(url: video)
    }
    return low
  }
  
  var low: AVAsset? {
    if let video = lowUrl {
      return AVURLAsset(url: video)
    }
    return nil
  }
  
  var highUrl: URL? {
    if let video = streamURLs[VideoQuality.high.videoKey] {
      return video
    }
    
    return mediumUrl
  }
  
  var mediumUrl: URL? {
    if let video = streamURLs[VideoQuality.medium.videoKey] {
      return video
    }
    
    return lowUrl
  }
  
  var lowUrl: URL? {
    if let video = streamURLs[VideoQuality.small.videoKey] {
      return video
      
    }
    return nil
  }
}
