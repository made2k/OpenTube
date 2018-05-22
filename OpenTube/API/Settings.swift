import UIKit

class Settings: NSObject {
  private static var defaults = UserDefaults.standard
  
  private static var rawDefaultSteramQuality: Int {
    get {
      return defaults.integer(forKey: "settings.defaultStreamQuality")
    }
    set {
      defaults.set(newValue, forKey: "settings.defaultStreamQuality")
    }
  }
  
  static var defaultStreamQuality: VideoQuality {
    get {
      return VideoQuality(rawValue: rawDefaultSteramQuality) ?? .high
    }
    set {
      rawDefaultSteramQuality = newValue.rawValue
    }
  }
  
  private static var rawDefaultDownloadQuality: Int {
    get {
      return defaults.integer(forKey: "settings.defaultDownloadQuality")
    }
    set {
      defaults.set(newValue, forKey: "settings.defaultDownloadQuality")
    }
  }
  
  static var defaultDownloadQuality: VideoQuality {
    get {
      return VideoQuality(rawValue: rawDefaultDownloadQuality) ?? .high
    }
    set {
      rawDefaultDownloadQuality = newValue.rawValue
    }
  }

  static var backgroudFetchInterval: TimeInterval {
    get {
      let savedInterval = defaults.double(forKey: "settings.backgroundFetchInterval")
      if savedInterval == 0 {
        return 30 * 60
      }
      
      return savedInterval
    }
    set {
      let value = max(newValue, 10 * 30)
      defaults.set(value, forKey: "settings.backgroundFetchInterval")
    }
  }
}
