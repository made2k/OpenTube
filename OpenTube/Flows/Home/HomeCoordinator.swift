
import DataModels
import UIKit

final class HomeCoordinator: NSObject, Coordinator {

  private let navigation: UINavigationController
  private lazy var vc: UIViewController = {
    return HomeViewController(delegate: self)
  }()

  private var childCoordinator: Coordinator?
  
  init(navigation: UINavigationController) {
    self.navigation = navigation
  }
  
  func start() {
    navigation.setViewControllers([vc], animated: false)
  }

}

extension HomeCoordinator: HomeViewControllerDelegate {

  var rootViewController: UIViewController {
    return navigation
  }
  
  func homeControllerDidViewUpNextAll() {
    let list = VideoListCoordinator(navigation: navigation,
                                    listTitle: "Up Next",
                                    videoRelay: UpNextModel.shared.videoList)
    list.start()
    childCoordinator = list
  }

  func homeControllerDidSelectChannel(_ model: ChannelModel) {
    let list = VideoListCoordinator(navigation: navigation,
                                    listTitle: model.channelName,
                                    videoRelay: model.videos)
    list.start()
    childCoordinator = list
  }
  
}
