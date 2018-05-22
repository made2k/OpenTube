import UIKit
import AsyncDisplayKit

class AddChannelViewController: UIViewController {
  
  @IBOutlet weak var channelIdTextField: UITextField!
  
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
  @IBAction func addChannelButtonPressed(_ sender: Any) {
    guard let text = channelIdTextField.text, !text.isEmpty else { return }
    SubscribedChannel.create(with: text)
    dismiss(animated: true, completion: nil)
  }
}
