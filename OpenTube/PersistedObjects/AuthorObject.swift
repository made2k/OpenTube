import UIKit
import RealmSwift

/**
 A Realm object representing an Author of a Video Entry.
 */
class AuthorObject: Object {
  
  @objc dynamic var name: String = ""
  
  /// String representation of the authors channel URL.
  @objc dynamic var linkString: String = ""
  
  convenience init(author: ChannelAuthor) {
    self.init()
    name = author.name
    linkString = author.link.absoluteString
  }
}
