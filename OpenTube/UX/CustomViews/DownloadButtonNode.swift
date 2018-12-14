
import AsyncDisplayKit
import FFCircularProgressView

final class DownloadButtonNode: ASControlNode {

  private var preloadProgress: CGFloat = 0
  private var progressView: FFCircularProgressView?

  override init() {
    super.init()
    style.preferredSize = CGSize(width: 25, height: 25)
  }

  override func didLoad() {
    super.didLoad()

    let progressView = FFCircularProgressView()
    progressView.progress = preloadProgress
    view.addSubview(progressView)
    self.progressView = progressView
  }

  override func layoutDidFinish() {
    super.layoutDidFinish()
    progressView?.frame = view.bounds
  }
  
  func updateProgress(_ progress: CGFloat) {

    guard isNodeLoaded else {
      preloadProgress = progress
      return
    }

    DispatchQueue.main.async {

      if self.isNodeLoaded == false {
        self.preloadProgress = progress

      } else {
        self.progressView?.progress = progress
      }
    }
  }

}
