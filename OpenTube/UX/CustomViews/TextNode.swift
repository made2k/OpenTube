import UIKit
import AsyncDisplayKit

class TextNode: ASTextNode {
  private static let defaultFont = UIFont.systemFont(ofSize: 15)
  private static let defaultFontColor = UIColor(hex: "1B1B1C")
  
  private var customAttributes: [NSAttributedStringKey: Any] = [
    NSAttributedStringKey.font: TextNode.defaultFont,
    NSAttributedStringKey.foregroundColor: TextNode.defaultFontColor
  ]
  
  var font: UIFont {
    get {
      return customAttributes[.font] as? UIFont ?? TextNode.defaultFont
    }
    set {
      customAttributes[.font] = newValue
      reloadAttributedString()
    }
  }
  
  var textColor: UIColor {
    get {
      return customAttributes[.foregroundColor] as? UIColor ?? TextNode.defaultFontColor
    }
    set {
      customAttributes[.foregroundColor] = newValue
      reloadAttributedString()
    }
  }
  
  var text: String? {
    get {
      return attributedText?.string
    }
    set {
      if let newValue = newValue {
        attributedText = NSAttributedString(string: newValue, attributes: customAttributes)
      } else {
        attributedText = nil
      }
    }
  }
  
  override init() {
    super.init()
    maximumNumberOfLines = 1
  }
  
  private func reloadAttributedString() {
    let text = self.text
    self.text = text
  }
  
}
