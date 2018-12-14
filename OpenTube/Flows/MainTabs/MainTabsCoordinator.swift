
import DataModels
import UIKit

class MainTabsCoordinator: NSObject, Coordinator {
  
  private let navigation: UINavigationController
  
  private let tabController = UITabBarController()
  
  private let homeCoordinator: HomeCoordinator
  private let allVideoCoordinator: VideoListCoordinator
  private let webBrowsingCoordinator: WebBrowsingCoordinator
  private let settingsCoordinator: SettingsCoordinator
  
  private var coordinators: [Coordinator] {
    return [homeCoordinator, allVideoCoordinator, webBrowsingCoordinator, settingsCoordinator]
  }
  
  init(navigation: UINavigationController) {
    self.navigation = navigation
    
    let homeNavigation = UINavigationController()
    homeNavigation.tabBarItem = UITabBarItem(title: "Home", image: R.image.tabHome(), selectedImage: nil)
    homeCoordinator = HomeCoordinator(navigation: homeNavigation)

    let allVideoNavigation = UINavigationController()
    allVideoNavigation.tabBarItem = UITabBarItem(title: "Videos", image: R.image.tabVideos(), selectedImage: nil)
    allVideoCoordinator = VideoListCoordinator(navigation: allVideoNavigation,
                                               listTitle: "Videos",
                                               videoRelay: VideoListModel.shared.videoList)
    
    let webNavigation = UINavigationController()
    webNavigation.tabBarItem = UITabBarItem(title: "Browse", image: R.image.tabBrowse(), selectedImage: nil)
    webBrowsingCoordinator = WebBrowsingCoordinator(navigation: webNavigation)

    let settingsNavigation = UINavigationController()
    settingsNavigation.tabBarItem = UITabBarItem(title: "Settings", image: R.image.tabSettings(), selectedImage: nil)
    settingsCoordinator = SettingsCoordinator(navigation: settingsNavigation)
    
    tabController.viewControllers = [homeNavigation, allVideoNavigation, webNavigation, settingsNavigation]
  }
  
  func start() {
    coordinators.forEach { $0.start() }
    navigation.setViewControllers([tabController], animated: false)
  }

}
