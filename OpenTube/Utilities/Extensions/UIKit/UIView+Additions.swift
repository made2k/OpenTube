
import UIKit
import MBProgressHUD
import PromiseKit

extension UIView {

  func showError(text: String?, duration: TimeInterval = 2) {

    let hud = MBProgressHUD.showAdded(to: self, animated: true)
    hud.mode = .text
    hud.label.text = text

    after(seconds: duration).done {
      MBProgressHUD.hide(for: self, animated: true)
    }

  }

}
