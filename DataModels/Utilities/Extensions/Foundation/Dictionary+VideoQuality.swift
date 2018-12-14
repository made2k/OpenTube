
extension Dictionary where Key == VideoQuality, Value == URL {
  
  func qualityLessOrEqual(_ quality: VideoQuality) -> URL? {
    var availableQualities: [VideoQuality] = []
    
    switch quality {
    case .high:
      availableQualities = [.high, .medium, .low]
    case .medium:
      availableQualities = [.medium, .low]
    case .low:
      availableQualities = [.low]
    }
    
    for quality in availableQualities {
      if let url = self[quality] {
        return url
      }
    }
    
    return nil
  }
}
