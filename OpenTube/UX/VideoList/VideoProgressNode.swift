
import AsyncDisplayKit

final class VideoProgressNode: ASDisplayNode {

  private let height: CGFloat = 6

  var progress: CGFloat = 0 {
    didSet {
      let safeProgress = max(min(1, progress), 0)

      isHidden = safeProgress < 0.03

      foregroundNode.style.width = ASDimension(unit: .fraction, value: safeProgress)
      foregroundNode.setNeedsLayout()
      self.setNeedsLayout()
    }
  }

  private let foregroundNode: ASDisplayNode = {
    let node = ASDisplayNode()
    node.backgroundColor = .white
    return node
  }()

  override init() {
    super.init()

    automaticallyManagesSubnodes = true

    backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)

    style.height = ASDimension(unit: .points, value: height)
    style.width = ASDimension(unit: .fraction, value: 1)
    cornerRadius = height / 2

    clipsToBounds = true

    isHidden = true
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    return ASRelativeLayoutSpec(horizontalPosition: .start,
                                verticalPosition: .center,
                                sizingOption: .minimumWidth,
                                child: foregroundNode)
  }

}
