
import AsyncDisplayKit
import DataModels
import RxSwift
import Then

final class VideoDisplayNode: ASDisplayNode {

  let videoModel: VideoModel

  private let thumbnailNode = ASNetworkImageNode().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
  }
  private let progressNode = VideoProgressNode()
  private let durationNode = TextNode().then {
    $0.textColor = UIColor.white
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.cornerRadius = 3
    $0.backgroundColor = UIColor.black
  }
  private let titleNode = TextNode().then {
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.style.flexShrink = 1
    $0.textColor = UIColor(hex: "0e0c26")
    $0.maximumNumberOfLines = 2
  }
  private let detailTextNode = TextNode().then {
    $0.font = UIFont.systemFont(ofSize: 12)
    $0.truncationMode = .byTruncatingMiddle
    $0.style.flexShrink = 1
    $0.textColor = UIColor(hex: "6c6b70")
  }
  private let channelThumbnailNode = ASNetworkImageNode().then {
    $0.style.preferredSize = CGSize(width: 25, height: 25)
    $0.contentMode = .scaleAspectFit
  }

  let downloadButton = DownloadButtonNode()

  var longPressAction: ((VideoModel) -> Void)?

  private let disposeBag = DisposeBag()

  init(_ entry: VideoModel) {
    self.videoModel = entry

    super.init()

    automaticallyManagesSubnodes = true

    backgroundColor = UIColor.white

    clipsToBounds = true

    channelThumbnailNode.url = entry.channel?.channelThumbnail

    thumbnailNode.url = entry.thumbnailUrl
    titleNode.text = entry.title
    detailTextNode.text = entry.detailDescription

    downloadButton.tapAction = { [weak self] in
      self?.downloadVideo()
    }

    setupBindings()
  }

  override func didLoad() {
    super.didLoad()

    setupLongPress()
    setNeedsLayout()
  }

  private func setupBindings() {

    // Update watch percentage
    videoModel.watchProgress.asObservable()
      .distinctUntilChanged()
      .map { CGFloat($0) }
      .subscribe(onNext: { [unowned self] progress in
        self.progressNode.progress = progress
      }).disposed(by: disposeBag)

    // Update is watched status
    videoModel.isWatched.asObservable()
      .map { $0 ? 0.8 : 1}
      .subscribe(onNext: { [unowned self] alpha in
        self.thumbnailNode.alpha = alpha
      }).disposed(by: disposeBag)

    // Show / hide duration label
    videoModel.durationDescription.asObservable()
      .map { $0 == nil }
      .distinctUntilChanged()
      .subscribe(onNext: { [unowned self] isHidden in
        self.durationNode.isHidden = isHidden
      }).disposed(by: disposeBag)

    videoModel.durationDescription.asObservable()
      .filterNil()
      .subscribe(onNext: { [unowned self] description in
        self.durationNode.text = description
      }).disposed(by: disposeBag)

    videoModel.downloadProgress.asObservable()
      .map { CGFloat($0) }
      .subscribe(onNext: { [unowned self] progress in
        self.downloadButton.updateProgress(progress)
      }).disposed(by: disposeBag)

    videoModel.hidden.asObservable()
      .subscribe(onNext: { [unowned self] _ in
        self.setNeedsLayout()
      }).disposed(by: disposeBag)
  }

  private func downloadVideo() {
    videoModel.handleDownloadAction(quality: AppSettings.defaultDownloadQuality)
  }
}

// MARK: - Gestures

extension VideoDisplayNode {

  private func setupLongPress() {
    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(cellWasLongPressed(sender:)))
    self.view.addGestureRecognizer(gesture)
  }

  @objc private func cellWasLongPressed(sender: UILongPressGestureRecognizer) {
    guard sender.state == .began else { return }
    longPressAction?(videoModel)
  }
}

// MARK: - Layout

extension VideoDisplayNode {

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let desiredSizeWidth = min(constrainedSize.max.width - 30, 330)

    let thumbnailRatio = ASRatioLayoutSpec(ratio: 9.0 / 16.0,
                                           child: thumbnailNode)

    let progressInsetSpec = ASInsetLayoutSpec()
    progressInsetSpec.insets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    progressInsetSpec.child = progressNode


    let progressRelativeSpec = ASRelativeLayoutSpec()
    progressRelativeSpec.horizontalPosition = .center
    progressRelativeSpec.verticalPosition = .end
    progressRelativeSpec.child = progressInsetSpec

    let overlay = ASOverlayLayoutSpec(child: thumbnailRatio, overlay: progressRelativeSpec)

    let textVertical = ASStackLayoutSpec()
    textVertical.direction = .vertical
    textVertical.style.flexShrink = 1
    textVertical.horizontalAlignment = .left
    textVertical.spacing = 2
    textVertical.children = [titleNode, ASLayoutSpec.spacer(), detailTextNode]

    let downloadChannelHorizontal = ASStackLayoutSpec.horizontal()
    downloadChannelHorizontal.children = [downloadButton, channelThumbnailNode]
    downloadChannelHorizontal.spacing = 8
    downloadChannelHorizontal.verticalAlignment = .center

    let spacer = ASLayoutSpec()
    spacer.style.flexGrow = 1

    let detailHorizontal = ASStackLayoutSpec()
    detailHorizontal.direction = .horizontal
    detailHorizontal.spacing = 8
    detailHorizontal.style.flexShrink = 1
    detailHorizontal.style.flexGrow = 1
    detailHorizontal.verticalAlignment = .center
    detailHorizontal.children = [textVertical, spacer, downloadChannelHorizontal]

    let detailInsetSpec = ASInsetLayoutSpec()
    detailInsetSpec.insets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    detailInsetSpec.child = detailHorizontal
    detailInsetSpec.style.flexGrow = 1

    let verticalStack = ASStackLayoutSpec.vertical()
    verticalStack.children = [overlay, detailInsetSpec]
    verticalStack.style.flexGrow = 1

    verticalStack.style.width = ASDimension(unit: .points, value: desiredSizeWidth)

    return verticalStack
  }

}
