import UIKit
import RealmSwift

protocol EntryObjectDelegate: class {
  func objectWasUpdated()
}

/**
 A Realm object that represents a Video Entry
 from the YouTube RSS feed.
 */
class EntryObject: Object {
  
  weak var delegate: EntryObjectDelegate?
  
  // Lookup ID
  @objc dynamic var channelId: String = ""
  
  // Video Properties
  @objc dynamic var videoId: String = ""
  @objc dynamic var title: String = ""
  @objc dynamic var publishDate: Date = Date()
  @objc dynamic var thumbnailString: String = ""
  @objc dynamic var videoDescription: String = ""
  
  @objc dynamic var author: AuthorObject? = AuthorObject()
  
  @objc dynamic var duration: Double = 0
  @objc dynamic var watchProgress: Double = 0
  
  @objc dynamic var hidden: Bool = false
  
  /**
   Returns a string formatted based on the date.
   This is in the style of YouTube formatting (ie. how long ago).
   For example you can get text like "3 minutes ago", "2 years ago"
   */
  var dateText: String {
    let interval = -1 * publishDate.timeIntervalSinceNow
    
    let plural: Bool = (interval.totalYears > 0 ? interval.totalYears :
      interval.totalMonths > 0 ? interval.totalMonths :
      interval.totalWeeks > 0 ? interval.totalWeeks :
      interval.totalDays > 0 ? interval.totalDays :
      interval.totalHours > 0 ? interval.totalHours :
      interval.totalMinutes > 0 ? interval.totalMinutes :
      0) != 1
    
    let sfx = plural ? "s" : ""
    
    if interval.totalYears > 0 { return "\(interval.totalYears) year\(sfx) ago" }
    if interval.totalMonths > 0 { return "\(interval.totalMonths) month\(sfx) ago" }
    if interval.totalWeeks > 0 && interval.totalWeeks < 5 { return "\(interval.totalWeeks) week\(sfx) ago" }
    if interval.totalDays > 0 { return "\(interval.totalDays) day\(sfx) ago" }
    if interval.totalHours > 0 { return "\(interval.totalHours) hour\(sfx) ago" }
    if interval.totalMinutes > 0 { return "\(interval.totalMinutes) minute\(sfx) ago" }
    
    return "Just now"
  }
  
  var durationText: String {
    guard duration > 0 else { return "" }
    
    let hours = Int(duration / 3600)
    let minutes = Int(duration.truncatingRemainder(dividingBy: 3600) / 60)
    let seconds = Int(duration.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))
    
    let hourString = hours > 0 ? "\(String(format: "%02d", hours)):" : ""
    
    return "\(hourString)\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
  }
  
  convenience init(entry: VideoEntry) {
    self.init()
    
    videoId = entry.videoId
    title = entry.title
    publishDate = entry.publishDate
    thumbnailString = entry.thumbnailUrl.absoluteString
    videoDescription = entry.videoDescription
    channelId = entry.channelId
    
    author = AuthorObject(author: entry.author)
  }
  
  func updateDuration(_ duration: Double) {
    try? realm?.write {
      self.duration = duration
    }
    
    delegate?.objectWasUpdated()
  }
  
  func updateProgress(_ progressPercent: Double) {
    try? realm?.write {
      self.watchProgress = progressPercent
    }
    
    delegate?.objectWasUpdated()
  }
  
}

fileprivate extension TimeInterval {
  
  var totalYears: Int {
    return totalMonths / 12
  }
  
  var totalMonths: Int {
    return totalDays / 30 // Meh
  }
  
  var totalWeeks: Int {
    return totalDays / 7
  }
  
  var totalDays: Int {
    return totalHours / 24
  }
  
  var totalHours: Int {
    return totalMinutes / 60
  }
  
  var totalMinutes: Int {
    return Int(self) / 60
  }
}
