
import AVKit
import DataModels
import PromiseKit
import RealmSwift
import SwiftyXML
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?

  private var startupCoordinator: StartupCoordinator?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    let audioSession = AVAudioSession.sharedInstance()
    try? audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
    
    VideoListModel.shared.configure()

    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    
    startupCoordinator = StartupCoordinator(window: window)
    startupCoordinator?.start()

    application.setMinimumBackgroundFetchInterval(AppSettings.backgroudFetchInterval)

    return true
  }

  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    firstly {
      VideoListModel.shared.fetchAndSaveNewVideos()

    }.filterValues { model -> Bool in
      model.channel?.notificationsEnabled.value == true

    }.then { notifyingModels -> Guarantee<[VideoModel]> in
      self.notifyNewVideos(notifyingModels)

    }.done { newVideos in
      completionHandler(newVideos.isEmpty ? .noData : .newData)

    }.catch { _ in
      completionHandler(.failed)
    }

  }

  private func notifyNewVideos(_ models: [VideoModel]) -> Guarantee<[VideoModel]> {

    return Guarantee { seal in

      UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in

        guard settings.authorizationStatus == .authorized else {
          return seal((models))
        }

        let guarantees = models.map { self?.notifyVideo($0) }.compactMap { $0 }
        when(guarantees: guarantees).done {
          seal(models)
        }
      }

    }

  }

  private func notifyVideo(_ model: VideoModel) -> Guarantee<Void> {

    var channelTitleSuffix: String = ""
    if let channelName = model.channel?.channelName {
      channelTitleSuffix = " from \(channelName)"
    }
    let title = "New Video\(channelTitleSuffix)"

    let content = UNMutableNotificationContent()
    content.title = title
    content.body = "\(model.title)"
    content.sound = UNNotificationSound.default

    // TODO: Download thumbnail and add attachment

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    return Guarantee { seal in

      UNUserNotificationCenter.current().add(request) { _ in
        seal(())
      }

    }
  }

}
