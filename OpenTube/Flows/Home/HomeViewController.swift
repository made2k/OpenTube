
import AsyncDisplayKit
import DataModels
import PromiseKit

protocol HomeViewControllerDelegate: VideoDisplayable {
  func homeControllerDidViewUpNextAll()
  func homeControllerDidSelectChannel(_ model: ChannelModel)
}

private enum Rows: Int, CaseIterable {
  case upNext
  case subscription
}

final class HomeViewController: ASViewController<ASTableNode> {

  private lazy var refreshControl: UIRefreshControl = {
    let refresh = UIRefreshControl()
    refresh.addTarget(self, action: #selector(reload), for: .valueChanged)
    return refresh
  }()
  private weak var delegate: HomeViewControllerDelegate?
  
  init(delegate: HomeViewControllerDelegate) {
    
    self.delegate = delegate
    
    let table = ASTableNode(style: .plain)
    
    super.init(node: table)
    
    table.dataSource = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    node.view.separatorStyle = .none
    node.view.refreshControl = refreshControl
    node.view.hideEmptyCells()

    // TODO: Is this a good place to fetch new videos? Probably not
    VideoListModel.shared.fetchAndSaveNewVideos().cauterize()
  }

  @objc private func reload() {
    let mainQ = DispatchQueue.main

    firstly {
      VideoListModel.shared.fetchAndSaveNewVideos()

    }.done(on: mainQ) { _ in
      self.node.reloadData()

    }.catch(on: mainQ) { _ in
      self.navigationController?.view.showError(text: "Failed to refresh videos")

    }.finally(on: mainQ) {
      self.refreshControl.endRefreshing()
    }
  }
  
}

extension HomeViewController: ASTableDataSource {
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return Rows.allCases.count
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let delegate = self.delegate
    
    switch indexPath.row {

    case Rows.upNext.rawValue:
      return { UpNextCellNode(delegate: delegate) }

    case Rows.subscription.rawValue:
      return { SubscriptionListCellNode(delegate: delegate) }

    default:
      fatalError()

    }
    
  }
  
}
