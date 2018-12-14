
import Foundation

extension Date {

  /**
   Returns a string formatted based on the date.
   This is in the style of YouTube formatting (ie. how long ago).
   For example you can get text like "3 minutes ago", "2 years ago"
   */
  public var ageDescription: String {
    let interval = -1 * self.timeIntervalSinceNow

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
