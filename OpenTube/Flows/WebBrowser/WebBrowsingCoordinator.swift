
import AVKit
import DataModels
import MBProgressHUD
import PromiseKit
import UIKit
import WebKit
import XCDYouTubeKit

protocol WebViewInterceptor: class {
  func webview(_ webview: WKWebView, isOpening url: URL)
}

final class WebBrowsingCoordinator: NSObject, Coordinator {
  
  private let navigation: UINavigationController
  
  private lazy var webBrowsingController: WebBrowsingViewController = {
    return WebBrowsingViewController(navigationDelegate: self)
  }()

  private var subscriptions: [ChannelModel] {
    return ChannelListModel.shared.subscriptions.value
  }
  
  init(navigation: UINavigationController) {
    self.navigation = navigation
  }
  
  func start() {
    navigation.setViewControllers([webBrowsingController], animated: false)
  }

  // MARK: - Button Setup

  private func setupSubscriptionButtons(channelId: String) {
    let subscribed = subscriptions.contains(where: { $0.channelId == channelId })
    let title = subscribed ? "Unsubscribe" : "Subscribe"
    let item = UIBarButtonItem(title: title, style: .done) { [weak self] _ in
      if subscribed {
        self?.unsubscribe(channelId: channelId)
      } else {
        self?.subscribe(channelId: channelId)
      }
    }
    webBrowsingController.navigationItem.rightBarButtonItem = item
  }

  private func setupSubscriptionButtons(channelName: String) {
    let subscribed = subscriptions.contains(where: { $0.channelName == channelName })
    let title = subscribed ? "Unsubscribe" : "Subscribe"
    let item = UIBarButtonItem(title: title, style: .done) { [weak self] _ in
      if subscribed {
        self?.unsubscribe(channelName: channelName)
      } else {
        self?.subscribe(channelName: channelName)
      }
    }
    webBrowsingController.navigationItem.rightBarButtonItem = item

  }

  private func clearSubscriptionButtons() {
    webBrowsingController.navigationItem.rightBarButtonItem = nil
  }

  // MARK: - Subscription Management

  private func unsubscribe(channelId: String) {
    guard let model = subscriptions.first(where: { $0.channelId == channelId }) else { return }
    ChannelListModel.shared.removeSubscription(model)
    setupSubscriptionButtons(channelId: channelId)
  }

  private func unsubscribe(channelName: String) {
    guard let model = subscriptions.first(where: { $0.channelName == channelName }) else { return }
    ChannelListModel.shared.removeSubscription(model)
    setupSubscriptionButtons(channelName: channelName)
  }

  private func subscribe(channelId: String) {
    let promise = ChannelListModel.shared.addSubscription(channelId: channelId)
    subscribe(promise: promise, channelName: nil, channelId: channelId)
  }

  private func subscribe(channelName: String) {
    let promise = ChannelListModel.shared.addSubscription(channelName: channelName)
    subscribe(promise: promise, channelName: channelName, channelId: nil)
  }

  private func subscribe(promise: Promise<Void>, channelName: String?, channelId: String?) {
    let hud = MBProgressHUD.showAdded(to: navigation.view, animated: true)
    hud.label.text = "Subscribing..."
    if let channelName = channelName {
      hud.label.text = "Subscribing to \(channelName)"
    }

    firstly {
      promise

    }.done {
      if let name = channelName {
        self.setupSubscriptionButtons(channelName: name)
      } else if let channelId = channelId {
        self.setupSubscriptionButtons(channelId: channelId)
      }

    }.recover { error -> Guarantee<Void> in
      hud.mode = .text
      hud.label.text = "Error subscribing"
      return after(seconds: 2)

    }.ensure {
      MBProgressHUD.hide(for: self.navigation.view, animated: true)

    }.cauterize()

  }

}

// MARK: - WKNavigationDelegate

extension WebBrowsingCoordinator: WKNavigationDelegate {
  
  func webView(_ webView: WKWebView,
               decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

    guard navigationAction.request.url?.host?.contains("youtube.com") == true else {
      return decisionHandler(.cancel)
    }
    decisionHandler(.allow)
  }

}

// MARK: - Interceptor

extension WebBrowsingCoordinator: WebViewInterceptor {

  // Intercept calls to user and channel to setup subscribe buttons
  func webview(_ webview: WKWebView, isOpening url: URL) {
    
    let pathComponents = url.path.components(separatedBy: "/").filter { $0.isNotEmpty }

    if let channelId = pathComponents.last, pathComponents.first == "channel" && pathComponents.count == 2 {
      return setupSubscriptionButtons(channelId: channelId)

    } else if let username = pathComponents.last, pathComponents.first == "user" && pathComponents.count == 2 {
      return setupSubscriptionButtons(channelName: username)

    } else {
      clearSubscriptionButtons()
    }
    
    guard let params = url.queryParameters else { return }
    guard let videoId = params["v"] else { return }

    loadVideo(with: videoId, webview: webview)
  }

  private func loadVideo(with videoId: String, webview: WKWebView) {

    XCDYouTubeClient.default().getVideoWithIdentifier(videoId) { [weak self] (video, error) in
      guard let video = video else { return }
      self?.playVideo(video: video, webview: webview)
    }

  }

  private func playVideo(video: XCDYouTubeVideo, webview: WKWebView) {
    
    let model = VideoModel(video: video)
    let playerController = PlayerViewController(videoModel: model, quality: nil)
    playerController.delegate = navigation

    navigation.present(playerController, animated: true) {
      webview.goBack()
    }
  }
}
