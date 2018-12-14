import UIKit
import DataModels

struct AppSettings {
  private static var defaults = UserDefaults.standard

  // MARK: - Stream Quality
  
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

  // MARK: - Download Quality
  
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

  // MARK: - Background Fetch

  static var backgroudFetchInterval: TimeInterval {
    get {
      let savedInterval = defaults.double(forKey: "settings.backgroundFetchInterval")
      if savedInterval == 0 {
        return 30 * 60
      }
      
      return savedInterval
    }
    set {
      let value = max(newValue, 5 * 60)
      defaults.set(value, forKey: "settings.backgroundFetchInterval")
    }
  }
}
