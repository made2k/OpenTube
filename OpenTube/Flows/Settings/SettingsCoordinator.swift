
import DataModels
import RxCocoa
import UIKit

final class SettingsCoordinator: NSObject, Coordinator {
  
  private let navigation: UINavigationController
  
  private lazy var settingsController: SettingsViewController = {
    return SettingsViewController(delegate: self)
  }()
  private var childCoordinator: Coordinator?
  
  init(navigation: UINavigationController) {
    self.navigation = navigation
  }
  
  func start() {
    navigation.setViewControllers([settingsController], animated: false)
  }

}

extension SettingsCoordinator: SettingsViewControllerDelegate {

  func settingsDidSelectChannelList() {
    childCoordinator = SubscriptionListCoordinator(navigation: navigation)
    childCoordinator?.start()
  }

  func settingsDidSelectDownloads() {
    let downloaded = VideoListModel.shared.getDownloadedVideos()
    let relay = BehaviorRelay<[VideoModel]>(value: downloaded)

    childCoordinator = VideoListCoordinator(navigation: navigation,
                                            listTitle: "Downloads",
                                            videoRelay: relay)
    childCoordinator?.start()
  }

  func settingsDidSelectHidden() {
    let hidden = VideoListModel.shared.getHiddenVideos()
    let relay = BehaviorRelay<[VideoModel]>(value: hidden)

    childCoordinator = VideoListCoordinator(navigation: navigation,
                                            listTitle: "Hidden",
                                            videoRelay: relay)
    childCoordinator?.start()
  }

  func settingsDidSelectAppSettings() {
    guard let vc = R.storyboard.settings.appSettings() else { return }
    navigation.pushViewController(vc, animated: true)
  }

  func settingsDidSelectLicenses() {
    let license = LicenseViewController()
    navigation.pushViewController(license, animated: true)
  }

}
