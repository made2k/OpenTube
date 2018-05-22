import UIKit

extension String {
  
  func substringAfter(_ substring: String) -> String? {
    guard let from = range(of: substring)?.upperBound else {
      return nil
    }
    
    return String(self[from..<endIndex])
  }
  
  func substring(after: String, before: String) -> String? {
    guard let from = range(of: after)?.upperBound else {
      return nil
    }
    
    // If not comparing between same strings, we can just lookup the before
    if after != before {
      guard let to = range(of: before, range: from..<endIndex)?.lowerBound else {
        return nil
      }
      
      return String(self[from..<to])
      
    } else {
      // We're looking for something between the same characters.
      guard let lastIndex = lastRange(of: before)?.lowerBound else {
        return nil
      }
      let to = index(lastIndex, offsetBy: 0)
      return String(self[from..<to])
    }
  }
  
  func lastRange(of substring: String) -> Range<String.Index>? {
    return range(of: substring, options: NSString.CompareOptions.backwards)
  }
  
}
