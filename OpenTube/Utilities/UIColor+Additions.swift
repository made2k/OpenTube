import UIKit

extension UIColor {
  
  // https://gist.github.com/arshad/de147c42d7b3063ef7bc
  convenience init(hex: String) {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if cString.hasPrefix("#") {
      cString.remove(at: cString.startIndex)
    }
    
    guard cString.count == 6 else {
      self.init(red: 0, green: 0, blue: 0, alpha: 1)
      return
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    self.init(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }

}
