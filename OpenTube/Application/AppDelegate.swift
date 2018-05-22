import UIKit
import UserNotifications
import SideMenu
import RealmSwift
import PromiseKit
import AVKit
import SwiftyXML

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    let audioSession = AVAudioSession.sharedInstance()
    try? audioSession.setCategory(AVAudioSessionCategoryPlayback)
    
    self.window = UIWindow(frame: UIScreen.main.bounds)
    
    let vc = VideoListViewController()
    let nav = UINavigationController(rootViewController: vc)
    
    window?.rootViewController = nav
    window?.makeKeyAndVisible()
    
    let leftMenu = MenuViewController()
    SideMenuManager.default.menuRightNavigationController = UISideMenuNavigationController(rootViewController: leftMenu)
    
    application.setMinimumBackgroundFetchInterval(Settings.backgroudFetchInterval)
    
    let options: UNAuthorizationOptions = [.alert, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
    }
    
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    guard let xml = XML(url: url) else { return false }
    guard let subscriptions = xml.children.first?.children.first?.children else { return false }
    
    var channelsToImport: [String] = []
    
    for child in subscriptions where child.name == "outline" {
      if let channelId = child.attributes["xmlUrl"]?.substringAfter("channel_id=") {
        channelsToImport.append(channelId)
      }
    }
    
    let alert = UIAlertController(title: "Import", message: "Would you like to import \(channelsToImport.count) subscriptions?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
      for channelId in channelsToImport {
        SubscribedChannel.create(with: channelId, notify: false)
      }
      NotificationCenter.default.post(name: Notifications.subscriptionListDidChange, object: nil)
    })
    alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
    window?.rootViewController?.present(alert, animated: true, completion: nil)
      
    return true
  }
  
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    let list = VideoEntryList(with: nil)
    
    let notifyingChannels = try! Realm().objects(SubscribedChannel.self).filter("notificationsEnabled == true").map { $0.channelId }
    
    firstly {
      list.fetchNewEntries()
      
    }.done { entries in
      self.notifyFor(channelsIds: Array(notifyingChannels), entries: entries, completion: completionHandler)
      
    }.catch { _ in
      completionHandler(.failed)
    }
    
  }
  
  private func notifyFor(channelsIds: [String], entries: [EntryObject], completion: @escaping (UIBackgroundFetchResult) -> Void) {
    var newVideos: [EntryObject] = []
    
    for entry in entries {
      if channelsIds.contains(entry.channelId) {
        newVideos.append(entry)
      }
    }
    
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      guard settings.authorizationStatus == .authorized else {
        return completion(newVideos.isEmpty ? .noData : .newData)
      }
      
      for video in newVideos {
        
        let content = UNMutableNotificationContent()
        content.title = "New Video"
        content.body = "\(video.title)"
        content.sound = UNNotificationSound.default()
        
        // TODO: Download thumbnail and add attachment
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error : Error?) in
          if let theError = error {
            print(theError.localizedDescription)
          }
        }
        
      }
      
      completion(entries.isEmpty ? .noData : .newData)
    }
  }
}
