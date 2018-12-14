
import AsyncDisplayKit
import DataModels
import Then

final class SubscribedChannelCellNode: ASCellNode {
  
  private let iconNode = ASNetworkImageNode().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.style.preferredSize = CGSize(width: 30, height: 30)
    $0.cornerRadius = 15
  }
  
  private let textNode = TextNode().then {
    $0.maximumNumberOfLines = 1
    $0.font = UIFont.systemFont(ofSize: 16)
    $0.textColor = .black
  }
  
  private let model: ChannelModel

  init(model: ChannelModel) {
    self.model = model
    
    super.init()
    
    automaticallyManagesSubnodes = true
    
    iconNode.url = model.channelThumbnail
    textNode.text = model.channelName
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let horizontalStack = ASStackLayoutSpec.horizontal()
    horizontalStack.children = [iconNode, textNode]
    horizontalStack.spacing = 12
    horizontalStack.verticalAlignment = .center
    
    let insetSpec = ASInsetLayoutSpec()
    insetSpec.insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    insetSpec.child = horizontalStack
    
    return insetSpec
  }
  
}
