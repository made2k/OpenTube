import UIKit
import AsyncDisplayKit
import FFCircularProgressView

class DownloadButtonNode: ASButtonNode {
  
  private var progressView = FFCircularProgressView()

  override init() {
    super.init()
    style.preferredSize = CGSize(width: 25, height: 25)
  }
  
  override func didLoad() {
    super.didLoad()
    view.addSubview(progressView)
  }
  
  override func layoutDidFinish() {
    super.layoutDidFinish()
    progressView.frame = view.bounds
  }
  
  func updateProgress(_ progress: CGFloat) {
    progressView.progress = progress
  }
}
