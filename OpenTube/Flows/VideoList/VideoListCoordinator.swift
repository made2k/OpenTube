
import DataModels
import RxCocoa
import UIKit

final class VideoListCoordinator: NSObject, Coordinator {

  private let navigation: UINavigationController

  private let relay: BehaviorRelay<[VideoModel]>
  private let listName: String

  init(navigation: UINavigationController,
       listTitle: String,
       videoRelay: BehaviorRelay<[VideoModel]>) {

    self.navigation = navigation

    self.relay = videoRelay
    self.listName = listTitle
  }

  func start() {
    let controller = VideoListViewController(title: listName,
                                             listRelay: relay,
                                             delegate: self)
    navigation.pushViewController(controller, animated: true)
  }

}

extension VideoListCoordinator: VideoDisplayable {

  var rootViewController: UIViewController {
    return navigation
  }

}
