import UIKit
import AsyncDisplayKit
import PromiseKit
import RxSwift
import DataModels

final class VideoCellNode: ASCellNode {
  
  let videoModel: VideoModel

  let videoDisplayNode: VideoDisplayNode

  init(_ videoModel: VideoModel, delegate: VideoDisplayable?) {
    self.videoModel = videoModel
    videoDisplayNode = VideoDisplayNode(videoModel)

    super.init()

    automaticallyManagesSubnodes = true

    clipsToBounds = false

    cornerRadius = 8
    videoDisplayNode.cornerRadius = 8

    shadowColor = UIColor.black.cgColor
    shadowOffset = CGSize(width: 0, height: 1)
    shadowOpacity = 0.25
    shadowRadius = 9
    
    style.height = ASDimension(unit: .points, value: 250)

    videoDisplayNode.longPressAction = { [unowned self] model in
      delegate?.videoWasLongPressed(model, view: self.view)
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let wrapper = ASWrapperLayoutSpec(layoutElement: videoDisplayNode)
    return wrapper
  }

}
