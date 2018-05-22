import UIKit
import AsyncDisplayKit
import PromiseKit

class EntryCellNode: ASCellNode {
  
  let entry: EntryObject
  
  let thumbnail = ASNetworkImageNode()
  let progressNode = ASDisplayNode()
  let durationNode = TextNode()
  let titleNode = TextNode()
  let authorNode = TextNode()
  let ageNode = TextNode()
  
  let downloadButton = DownloadButtonNode()
  
  var isDownloaded: Bool = false
  
  var longPressAction: ((EntryObject) -> Void)?
  
  init(_ entry: EntryObject) {
    self.entry = entry
    
    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    
    thumbnail.url = URL(string: entry.thumbnailString)
    thumbnail.contentMode = .scaleAspectFill
    
    progressNode.backgroundColor = UIColor.red.withAlphaComponent(0.85)
    progressNode.style.height = ASDimension(unit: .points, value: 8)
    progressNode.style.width = ASDimension(unit: .fraction, value: CGFloat(entry.watchProgress))
    
    alpha = entry.watchProgress >= 0.95 ? 0.6 : 1
    
    durationNode.textColor = UIColor.white
    durationNode.font = UIFont.systemFont(ofSize: 14)
    durationNode.cornerRadius = 3
    if entry.duration > 0 {
      durationNode.text = entry.durationText
      durationNode.backgroundColor = UIColor.black
    }
    
    titleNode.font = UIFont.systemFont(ofSize: 16)
    titleNode.style.flexShrink = 1
    titleNode.maximumNumberOfLines = 0
    titleNode.text = entry.title
    
    authorNode.font = UIFont.systemFont(ofSize: 14)
    authorNode.truncationMode = .byTruncatingMiddle
    authorNode.style.flexShrink = 1
    authorNode.textColor = UIColor.gray
    authorNode.text = (entry.author?.name ?? "Unknown") + " •"
    
    ageNode.font = authorNode.font
    ageNode.textColor = authorNode.textColor
    ageNode.text = entry.dateText
    
    downloadButton.addTarget(self, action: #selector(downloadVideo), forControlEvents: .touchUpInside)
    
    entry.delegate = self
  }
  
  override func didLoad() {
    super.didLoad()
    
    isDownloaded = DownloadManager.shared.isVideoAvailableLocally(entry)
    self.downloadButton.updateProgress(isDownloaded ? 1 : 0)
    
    setupLongPress()
    setNeedsLayout()
  }
  
  @objc func downloadVideo() {
    
    if isDownloaded {
      DownloadManager.shared.deleteDownload(for: entry)
      self.downloadButton.updateProgress(0)
      self.isDownloaded = false
      return
    }
    
    if DownloadManager.shared.isDownloading(entry: entry) {
      DownloadManager.shared.cancelDownload(for: entry)
      self.downloadButton.updateProgress(0)
      return
    }
    
    let progressBlock = { (progress: Double) in
      self.downloadButton.updateProgress(CGFloat(progress))
    }
    
    downloadButton.updateProgress(0.01)
    firstly {
      DownloadManager.shared.download(entry: entry, progress: progressBlock)
      
    } .done {
      self.isDownloaded = true
      
    }.done {
      self.setNeedsLayout()
      
    }.catch { _ in
      self.downloadButton.updateProgress(0)
    }
  }
  
}

// MARK: - Gestures

extension EntryCellNode {
  
  private func setupLongPress() {
    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(cellWasLongPressed(sender:)))
    self.view.addGestureRecognizer(gesture)
  }
  
  @objc private func cellWasLongPressed(sender: UILongPressGestureRecognizer) {
    guard sender.state == .began else { return }
    longPressAction?(entry)
  }
    
}

// MARK: - Entry Delegate

extension EntryCellNode: EntryObjectDelegate {

  func objectWasUpdated() {
    alpha = entry.watchProgress >= 0.95 ? 0.6 : 1
    progressNode.style.width = ASDimension(unit: .fraction, value: CGFloat(entry.watchProgress))

    if entry.duration > 0 {
      durationNode.attributedText = NSAttributedString(string: entry.durationText, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
      durationNode.backgroundColor = UIColor.black
    }
    
    setNeedsLayout()
    setNeedsDisplay()
  }
  
}


// MARK: - Layout

extension EntryCellNode {
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.spacing = 8
    verticalSpec.children = [thumbnailSpec(), textSpec()]

    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    inset.child = verticalSpec
    
    return inset
  }
  
  func thumbnailSpec() -> ASLayoutSpec {
    
    // Thumbnails are 16:9 ratio
    let ratioSpec = ASRatioLayoutSpec()
    ratioSpec.ratio = 9.0 / 16.0
    ratioSpec.child = thumbnail
    
    let overlay = ASOverlayLayoutSpec()
    overlay.child = ratioSpec
    overlay.overlay = progressSpec()
    
    return overlay
  }
  
  func progressSpec() -> ASLayoutSpec {
    
    let durationInset = ASInsetLayoutSpec()
    durationInset.insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    durationInset.child = durationNode
    
    let spacer = ASLayoutSpec()
    spacer.style.flexGrow = 1
    let durationHorizontal = ASStackLayoutSpec.horizontal()
    durationHorizontal.style.width = ASDimension(unit: .fraction, value: 1)
    durationHorizontal.children = [spacer, durationInset]
    
    let stack = ASStackLayoutSpec.vertical()
    stack.horizontalAlignment = .left
    stack.children = [durationHorizontal, progressNode]
    
    let relative = ASRelativeLayoutSpec()
    relative.verticalPosition = .end
    relative.style.width = ASDimension(unit: .fraction, value: 1)
    relative.child = stack
    
    return relative
  }
  
  func textSpec() -> ASLayoutSpec {
    
    let spacer = ASLayoutSpec()
    spacer.style.flexGrow = 1
    
    let text = ASStackLayoutSpec.horizontal()
    text.spacing = 3
    text.flexWrap = .wrap
    text.style.flexShrink = 1
    text.children = [authorNode, ageNode]
    
    let detailSpec = ASStackLayoutSpec.horizontal()
    detailSpec.spacing = 6
    detailSpec.verticalAlignment = .center
    detailSpec.children = [text, spacer, downloadButton]
    
    let titleDetail = ASStackLayoutSpec.vertical()
    titleDetail.children = [titleNode, detailSpec]
    
    return titleDetail
  }
}
