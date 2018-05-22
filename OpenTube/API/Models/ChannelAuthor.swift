import UIKit
import SwiftyXML

/// Representation of the Author in a Video Element.
class ChannelAuthor: NSObject {
  
  let name: String
  let link: URL
  
  init?(xml: XML) {
    guard let node = xml["author"].xml else { return nil }
    
    name = node["name"].stringValue
    link = URL(string: node["uri"].stringValue)!
  }
  
}
