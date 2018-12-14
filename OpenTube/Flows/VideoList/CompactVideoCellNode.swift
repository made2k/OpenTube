
import AsyncDisplayKit
import DataModels
import RxSwift

final class CompactVideoCellNode: ASCellNode {

  private let thumbnailNode = ASNetworkImageNode().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.cornerRadius = 5
    $0.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
    $0.borderWidth = 1
  }

  private let progressNode = VideoProgressNode()

  private let titleNode = TextNode().then {
    $0.font = UIFont.systemFont(ofSize: 15)
    $0.maximumNumberOfLines = 2
  }
  private let detailNode = TextNode().then {
    $0.font = UIFont.systemFont(ofSize: 11)
    $0.textColor = UIColor.lightGray
  }
  private let channelNode = TextNode().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.textColor = UIColor.lightGray
  }
  private let downloadNode = DownloadButtonNode()

  private let model: VideoModel
  private let disposeBag = DisposeBag()

  private var longPressAction: ((VideoModel) -> Void)?

  init(videoModel: VideoModel, delegate: VideoDisplayable?) {
    self.model = videoModel

    super.init()

    automaticallyManagesSubnodes = true
    selectionStyle = .none

    titleNode.text = videoModel.title
    channelNode.text = videoModel.channel?.channelName ?? "Unknown channel"
    thumbnailNode.url = videoModel.thumbnailUrl

    downloadNode.tapAction = { [weak self] in
      self?.model.handleDownloadAction(quality: AppSettings.defaultDownloadQuality)
    }
    longPressAction = { [unowned self] model in
      delegate?.videoWasLongPressed(model, view: self.view)
    }

    setupBindings()
  }

  override func didLoad() {
    super.didLoad()
    setupLongPress()
  }

  private func setupLongPress() {
    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(cellWasLongPressed(sender:)))
    self.view.addGestureRecognizer(gesture)
  }

  @objc private func cellWasLongPressed(sender: UILongPressGestureRecognizer) {
    guard sender.state == .began else { return }
    longPressAction?(model)
  }

  private func setupBindings() {

    model.isWatched.asObservable()
      .distinctUntilChanged()
      .map { $0 ? 0.6 : 1 }
      .subscribe(onNext: { [unowned self] in
        self.thumbnailNode.alpha = $0
      })
      .disposed(by: disposeBag)

    model.watchProgress.asObservable()
      .map { CGFloat($0) }
      .subscribe(onNext: { [unowned self] progress in
        self.progressNode.progress = progress
      }).disposed(by: disposeBag)

    model.durationDescription.asObservable()
      .subscribe(onNext: { [unowned self] durationString in

        self.detailNode.text = [durationString, self.model.publishDate.ageDescription]
          .compactMap { $0 }
          .joined(separator: " • ")

      }).disposed(by: disposeBag)

    model.downloadProgress.asObservable()
      .map { CGFloat($0) }
      .subscribe(onNext: { [unowned self] progress in
        self.downloadNode.updateProgress(progress)
      }).disposed(by: disposeBag)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let textVerticalSpec = ASStackLayoutSpec.vertical()
    textVerticalSpec.children = [titleNode, detailNode, channelNode]
    textVerticalSpec.spacing = 4
    textVerticalSpec.style.flexShrink = 1

    let thumbnailRatio = ASRatioLayoutSpec(ratio: 9.0/16.0, child: thumbnailNode)
    thumbnailRatio.style.width = ASDimension(unit: .points, value: 90)

    let progressInsetSpec = ASInsetLayoutSpec()
    progressInsetSpec.insets = UIEdgeInsets(top: 0, left: 6, bottom: 4, right: 6)
    progressInsetSpec.child = progressNode

    let progressRelativeSpec = ASRelativeLayoutSpec()
    progressRelativeSpec.horizontalPosition = .center
    progressRelativeSpec.verticalPosition = .end
    progressRelativeSpec.child = progressInsetSpec

    let thumbnailProgress = ASOverlayLayoutSpec(child: thumbnailRatio, overlay: progressRelativeSpec)

    let horizontalSpec = ASStackLayoutSpec.horizontal()
    horizontalSpec.children = [thumbnailProgress, textVerticalSpec, ASLayoutSpec.spacer(), downloadNode]
    horizontalSpec.verticalAlignment = .center
    horizontalSpec.spacing = 12

    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = horizontalSpec
    insetSpec.insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    return insetSpec
  }

}
