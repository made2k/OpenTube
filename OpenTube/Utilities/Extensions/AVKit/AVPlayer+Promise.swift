
import AVKit
import PromiseKit

extension AVPlayer {

  func seek(to time: TimeInterval) -> Guarantee<Void> {

    let cmTime = CMTime(seconds: time, preferredTimescale: 1)

    return Guarantee { seal in
      self.seek(to: cmTime) { _ in
        seal(())
      }
    }

  }

}
