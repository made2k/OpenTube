import UIKit
import AsyncDisplayKit

class DownloadCellNode: ASCellNode {
  
  let thumbnailNode = ASNetworkImageNode()
  let titleNode = TextNode()
  let authorNode = TextNode()
  let durationNode = TextNode()
  
  convenience init(downloadEntry: DownloadedEntry) {
    self.init(entry: downloadEntry.videoEntry)
  }
  
  init(entry: EntryObject) {
    let thumbnailHeight = 45
    let thumbnailWidth = thumbnailHeight * 16 / 9
    thumbnailNode.url = URL(string: entry.thumbnailString)
    thumbnailNode.style.preferredSize = CGSize(width: thumbnailWidth, height: thumbnailHeight)
    thumbnailNode.style.height = ASDimension(unit: .fraction, value: 1)
    
    titleNode.font = UIFont.systemFont(ofSize: 15)
    titleNode.text = entry.title
    
    authorNode.font = UIFont.systemFont(ofSize: 13)
    authorNode.textColor = UIColor.gray
    authorNode.text = (entry.author?.name ?? "Unknown") + " •"
    
    durationNode.font = authorNode.font
    durationNode.textColor = authorNode.textColor
    durationNode.text = entry.durationText

    super.init()
    automaticallyManagesSubnodes = true
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let authorDurationSpec = ASStackLayoutSpec.horizontal()
    authorDurationSpec.spacing = 2
    authorDurationSpec.children = [authorNode, durationNode]
    
    let textSpec = ASStackLayoutSpec.vertical()
    textSpec.spacing = 4
    textSpec.children = [titleNode, authorDurationSpec]
    
    let textInset = ASInsetLayoutSpec()
    textInset.insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    textInset.style.flexShrink = 1
    textInset.child = textSpec
    
    let horizontalSpec = ASStackLayoutSpec.horizontal()
    horizontalSpec.children = [thumbnailNode, textInset]
    
    return horizontalSpec
  }

}
