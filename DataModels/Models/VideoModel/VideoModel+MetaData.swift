
import PromiseKit
import XCDYouTubeKit

extension VideoModel {

  /**
   Fetch the video URLs for the file and associate them with quality.

   - Parameter force: Force a fetch. If this is false and we already have
   stored video qualities, those qualities will be returned.
   */
  func fetchVideoQualities(force: Bool = false) -> Promise<[VideoQuality: URL]> {
    if videoQualities.isNotEmpty && !force {  return .value(videoQualities) }

    return XCDYouTubeClient.default.getYoutubeVideo(videoModel: self)
      .map(parseVideoQualities)
      .get { self.videoQualities = $0 }
  }

  private func parseVideoQualities(_ video: XCDYouTubeVideo) -> [VideoQuality: URL] {
    self.duration.accept(video.duration)
    
    var returnValue: [VideoQuality: URL] = [:]

    returnValue[.high] = video.urlWithQuality(.high)
    returnValue[.medium] = video.urlWithQuality(.medium)
    returnValue[.low] = video.urlWithQuality(.low)

    return returnValue
  }

}
