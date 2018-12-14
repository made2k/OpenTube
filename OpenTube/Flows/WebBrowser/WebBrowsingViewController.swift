
import SnapKit
import UIKit
import WebKit

final class WebBrowsingViewController: UIViewController {
  
  private let webView: WKWebView
  private weak var interceptor: WebViewInterceptor?
  
  init(navigationDelegate: WKNavigationDelegate & WebViewInterceptor) {

    let configuration = WKWebViewConfiguration().then {
      $0.websiteDataStore = WKWebsiteDataStore.nonPersistent()
      $0.mediaTypesRequiringUserActionForPlayback = [.all]
    }
    
    self.webView = WKWebView(frame: .zero, configuration: configuration)
    self.webView.navigationDelegate = navigationDelegate
    
    self.interceptor = navigationDelegate
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    view.addSubview(webView)
    view.backgroundColor = .white

    webView.snp.makeConstraints { make in
      make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
    }

    loadHomePage()
    
    webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
  }
  
  private func loadHomePage() {
    guard let url = URL(string: "https://www.youtube.com") else { return }
    let request = URLRequest(url: url)
    webView.load(request)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard keyPath?.lowercased() == "url" else { return }
    guard let interceptor = interceptor else { return }
    guard let url = webView.url else { return }
    interceptor.webview(webView, isOpening: url)
  }
}
