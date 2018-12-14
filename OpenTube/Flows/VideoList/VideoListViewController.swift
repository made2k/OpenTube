
import AsyncDisplayKit
import DataModels
import RxCocoa
import RxSwift

final class VideoListViewController: ASViewController<ASTableNode> {

  private let videoList: BehaviorRelay<[VideoModel]>
  private let disposeBag = DisposeBag()
  private weak var delegate: VideoDisplayable?

  init(title: String,
       listRelay: BehaviorRelay<[VideoModel]>,
       delegate: VideoDisplayable?) {

    self.videoList = listRelay
    self.delegate = delegate

    let table = ASTableNode(style: .plain)

    super.init(node: table)

    table.dataSource = self
    table.delegate = self

    self.title = title

    setupBindings()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    node.view.hideEmptyCells()
  }

  private func setupBindings() {
    videoList.asObservable()
      .distinctUntilChanged()
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [unowned self] _ in
        self.node.reloadData()
      }).disposed(by: disposeBag)
  }

}

extension VideoListViewController: ASTableDataSource {

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return videoList.value.count
  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let model = videoList.value[indexPath.row]
    let delegate = self.delegate
    return { CompactVideoCellNode(videoModel: model, delegate: delegate) }
  }

}

extension VideoListViewController: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let model = videoList.value[indexPath.row]
    delegate?.playVideo(model, quality: nil)
  }

}
