
import AsyncDisplayKit
import DataModels
import Rswift
import RxSwift

final class SubscribedChannelEditableCellNode: ASCellNode {

  private let imageNode = ASNetworkImageNode().then {
    $0.cornerRadius = 20
    $0.style.preferredSize = CGSize(width: 40, height: 40)
  }
  private let titleNode = TextNode()
  private let notificatonNode = ASImageNode().then {
    $0.style.preferredSize = CGSize(width: 32, height: 32)
  }

  private let model: ChannelModel

  private weak var delegate: SubscribedChannelsViewControllerDelegate?

  private let disposeBag = DisposeBag()

  init(model: ChannelModel, delegate: SubscribedChannelsViewControllerDelegate?) {

    self.model = model
    self.delegate = delegate

    super.init()

    automaticallyManagesSubnodes = true

    imageNode.url = model.channelThumbnail

    notificatonNode.tapAction = {
      delegate?.didChangeNotifications(for: model)
    }

    titleNode.text = model.channelName

    setupBindings()
  }

  private func setupBindings() {

    model.notificationsEnabled.asObservable()
      .map { $0 ? R.image.ic_notification_enabled() : R.image.ic_notification_disabled() }
      .subscribe(onNext: { [unowned self] image in
        self.notificatonNode.image = image
      }).disposed(by: disposeBag)

  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.verticalAlignment = .center
    horizontal.spacing = 8
    horizontal.children = [imageNode, titleNode, ASLayoutSpec.spacer(), notificatonNode]

    inset.child = horizontal

    return inset
  }

}
