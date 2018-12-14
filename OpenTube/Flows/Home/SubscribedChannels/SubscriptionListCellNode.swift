
import AsyncDisplayKit
import DataModels
import RxSwift
import Then

final class SubscriptionListCellNode: ASCellNode {
  
  private let subscribedHeaderNode = TextNode().then {
    $0.font = UIFont.boldSystemFont(ofSize: 18)
    $0.textColor = .black
    $0.text = "Subscriptions"
  }

  private lazy var tableNode: ASTableNode = {
    let node = ASTableNode(style: .plain)
    node.dataSource = self
    node.delegate = self

    node.onDidLoad { _ in
      node.view.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    return node
  }()
  
  private var delegate: HomeViewControllerDelegate?
  private let disposeBag = DisposeBag()
  
  private var datasource: [ChannelModel] {
    return ChannelListModel.shared.subscriptions.value
  }
  
  init(delegate: HomeViewControllerDelegate?) {
    self.delegate = delegate
    
    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
  }
  
  override func didLoad() {
    super.didLoad()
    setupBindings()
  }

  private func setupBindings() {

    // Reload the data when our channels change
    ChannelListModel.shared.subscriptions.asObservable()
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [unowned self] _ in
        self.tableNode.reloadData()
      }).disposed(by: disposeBag)

    // When our table size changes, we need to update the prefered size and relayout
    tableNode.view.rx.observe(CGSize.self, "contentSize").asObservable()
      .filterNil()
      .distinctUntilChanged()
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .subscribe(onNext: { [unowned self] size in
        self.tableNode.style.preferredSize = size
        self.setNeedsLayout()
      }).disposed(by: disposeBag)

  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let headerInsetSpec = ASInsetLayoutSpec()
    headerInsetSpec.child = subscribedHeaderNode
    headerInsetSpec.insets = UIEdgeInsets(top: 16, left: 16, bottom: 12, right: 16)

    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.children = [headerInsetSpec, tableNode]
    
    return verticalSpec
  }
  
}

extension SubscriptionListCellNode: ASTableDataSource {
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return datasource.count
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let model = datasource[indexPath.row]
    return { SubscribedChannelCellNode(model: model) }
  }
  
}

extension SubscriptionListCellNode: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    tableNode.deselectRow(at: indexPath, animated: true)

    let model = datasource[indexPath.row]
    delegate?.homeControllerDidSelectChannel(model)
  }

}
