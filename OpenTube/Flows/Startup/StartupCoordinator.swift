
import Then
import UIKit

final class StartupCoordinator: NSObject, Coordinator {
  
  private let window: UIWindow
  
  private let navigation = UINavigationController().then {
    $0.setNavigationBarHidden(true, animated: false)
  }
  
  private var childCoordinator: Coordinator?
  
  init(window: UIWindow) {
    self.window = window
  }
  
  func start() {
    setupWindow()
    startChildCoordinator()
  }
  
  private func setupWindow() {
    window.rootViewController = navigation
    window.makeKeyAndVisible()
  }

  private func startChildCoordinator() {
    childCoordinator = MainTabsCoordinator(navigation: navigation)
    childCoordinator?.start()
  }

}
