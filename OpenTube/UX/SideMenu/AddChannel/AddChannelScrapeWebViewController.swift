import UIKit
import WebKit
import Alamofire
import RealmSwift

class AddChannelScrapeWebViewController: UIViewController {
  let realm = try! Realm()
  
  @IBOutlet weak var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let url = URL(string: "https://www.youtube.com")!
    let request = URLRequest(url: url)
    webView.load(request)
  }
  
  @IBAction func addChannelButtonPressed(_ sender: Any) {
    guard let url = webView.url else { return }
    
    // Load the HTML and look for Channel ID
    Alamofire.request(url).responseString { response in
      guard let string = response.value else {
        return self.showAlert(title: "No content", message: "Could not grab page HTML")
      }
      
      guard let channelId = string.substring(after: "\"channelId\" content=\"", before: "\"") else {
        return self.showAlert(title: "No channel ID", message: "Could not parse the channel ID")
      }
      SubscribedChannel.create(with: channelId)
      
      self.dismiss(animated: true, completion: nil)
    }
    
  }
}
