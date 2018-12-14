
import UIKit

extension UITableView {
  
  func hideEmptyCells() {
    guard tableFooterView == nil else { return }
    tableFooterView = UIView()
  }
  
}
