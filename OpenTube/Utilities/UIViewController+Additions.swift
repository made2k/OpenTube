import UIKit

extension UIViewController {
  func showAlert(title: String? = nil, message: String? = nil) {
    assert(title != nil || message != nil, "Title or message must not be nil.")
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
    
    present(alert, animated: true, completion: nil)
  }
}
