
import DataModels
import UIKit
import UserNotifications

final class SubscriptionListCoordinator: NSObject, Coordinator {

  private let navigation: UINavigationController
  private lazy var listController: SubscribedChannelsViewController = {
    let channelRelay = ChannelListModel.shared.subscriptions
    let controller = SubscribedChannelsViewController(channelRelay: channelRelay,
                                                      delegate: self)
    return controller
  }()

  private var childCoordinator: Coordinator?

  init(navigation: UINavigationController) {
    self.navigation = navigation

    super.init()
  }

  func start() {
    navigation.pushViewController(listController, animated: true)
  }

}

extension SubscriptionListCoordinator: SubscribedChannelsViewControllerDelegate {

  func didSelectChannelModel(_ model: ChannelModel) {
    childCoordinator = VideoListCoordinator(navigation: navigation,
                                            listTitle: model.channelName,
                                            videoRelay: model.videos)
    childCoordinator?.start()
  }

  func didChangeNotifications(for model: ChannelModel) {
    let newValue = !model.notificationsEnabled.value
    model.notificationsEnabled.accept(newValue)

    if newValue {
      requestNotificationAccess()
    }
  }

  func didDeleteModel(_ model: ChannelModel) {
    ChannelListModel.shared.removeSubscription(model)
  }

  private func requestNotificationAccess() {
    let options: UNAuthorizationOptions = [UNAuthorizationOptions.alert, .sound]

    UNUserNotificationCenter.current()
      .requestAuthorization(options: options) { granted, error in }
  }

}
