
import AsyncDisplayKit
import DataModels
import RxCocoa

protocol SubscribedChannelsViewControllerDelegate: class {
  func didSelectChannelModel(_ model: ChannelModel)
  func didChangeNotifications(for model: ChannelModel)
  func didDeleteModel(_ model: ChannelModel)
}

final class SubscribedChannelsViewController: ASViewController<ASTableNode> {

  private let relay: BehaviorRelay<[ChannelModel]>
  private var datasource: [ChannelModel] { return relay.value }

  private weak var delegate: SubscribedChannelsViewControllerDelegate?

  init(channelRelay: BehaviorRelay<[ChannelModel]>, delegate: SubscribedChannelsViewControllerDelegate) {

    self.relay = channelRelay
    self.delegate = delegate

    let node = ASTableNode(style: .plain)

    super.init(node: node)

    node.dataSource = self
    node.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    node.view.hideEmptyCells()
  }

}

extension SubscribedChannelsViewController: ASTableDataSource {

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return datasource.count
  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let model = datasource[indexPath.row]
    let delegate = self.delegate
    
    return { SubscribedChannelEditableCellNode(model: model, delegate: delegate) }
  }

}

extension SubscribedChannelsViewController: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let model = datasource[indexPath.row]
    delegate?.didSelectChannelModel(model)
  }

  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    guard delegate != nil else { return .none }
    return .delete
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard let delegate = delegate else { return }

    let model = datasource[indexPath.row]

    delegate.didDeleteModel(model)
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }

}
