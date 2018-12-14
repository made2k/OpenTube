
import AsyncDisplayKit
import DataModels
import RxSwift
import Then

/**
 This cell node handles the Up Next collection node
 */
final class UpNextCellNode: ASCellNode {
  
  private let upNextTitleNode = TextNode().then {
    $0.font = UIFont.boldSystemFont(ofSize: 19)
    $0.textColor = UIColor.black
    $0.text = "Up Next"
  }

  private let seeAllNode = ASButtonNode().then {
    let color = UIColor(hex: "52bbf7")
    $0.setTitle("See All",
                with: UIFont.systemFont(ofSize: 16),
                with: color,
                for: .normal)
  }

  private let collectionFlow = UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 16
    $0.scrollDirection = .horizontal
  }
  private lazy var videoCollectionNode: ASCollectionNode = {
    let node = ASCollectionNode(collectionViewLayout: collectionFlow)
    node.style.height = ASDimension(unit: .points, value: 290)
    node.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    node.dataSource = self
    node.delegate = self

    node.onDidLoad { _ in
      node.showsHorizontalScrollIndicator = false
    }

    return node
  }()
  
  private let separatorNode = ASDisplayNode().then {
    $0.style.width = ASDimension(unit: .fraction, value: 0.8)
    $0.style.height = ASDimension(unit: .points, value: 1)
    $0.backgroundColor = UIColor.black.withAlphaComponent(0.2)
  }

  private var videoDatasource: [VideoModel] {
    return UpNextModel.shared.videoList.value
  }
  
  private weak var delegate: HomeViewControllerDelegate?
  private let disposeBag = DisposeBag()
  
  init(delegate: HomeViewControllerDelegate?) {
    
    self.delegate = delegate
    
    super.init()

    automaticallyManagesSubnodes = true
    selectionStyle = .none
    
    seeAllNode.tapAction = { [weak self] in
      self?.delegate?.homeControllerDidViewUpNextAll()
    }

    setupBindings()
  }

  private func setupBindings() {

    UpNextModel.shared.videoList.asObservable()
      .distinctUntilChanged()
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [unowned self] _ in
        self.videoCollectionNode.reloadData()
      }).disposed(by: disposeBag)

  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [upNextTitleNode, ASLayoutSpec.spacer(), seeAllNode]
    
    let buttonInset = ASInsetLayoutSpec()
    buttonInset.insets = UIEdgeInsets(top: 12, left: 16, bottom: 4, right: 16)
    buttonInset.child = horizontal
    
    let separatorSpec = ASStackLayoutSpec.horizontal()
    separatorSpec.children = [ASLayoutSpec.spacer(), separatorNode, ASLayoutSpec.spacer()]
    
    let vertical = ASStackLayoutSpec.vertical()
    vertical.children = [buttonInset, videoCollectionNode, separatorSpec]
    
    return vertical
  }
  
}

extension UpNextCellNode: ASCollectionDataSource {
  
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return videoDatasource.count
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let model = videoDatasource[indexPath.row]
    let delegate = self.delegate

    return { VideoCellNode(model, delegate: delegate) }
  }
}

extension UpNextCellNode: ASCollectionDelegate {
  
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    let model = videoDatasource[indexPath.row]
    delegate?.playVideo(model, quality: nil)
  }
  
}
