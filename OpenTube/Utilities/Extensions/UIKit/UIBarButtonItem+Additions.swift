
import UIKit

// From: https://medium.com/@BeauNouvelle/adding-a-closure-to-uibarbuttonitem-24dfc217fe72

/// Typealias for UIBarButtonItem closure.
typealias UIBarButtonItemTargetClosure = (UIBarButtonItem) -> ()

class UIBarButtonItemClosureWrapper: NSObject {
  let closure: UIBarButtonItemTargetClosure
  init(_ closure: @escaping UIBarButtonItemTargetClosure) {
    self.closure = closure
  }
}

extension UIBarButtonItem {

  private struct AssociatedKeys {
    static var targetClosure = "targetClosure"
  }

  private var targetClosure: UIBarButtonItemTargetClosure? {
    get {
      guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? UIBarButtonItemClosureWrapper else { return nil }
      return closureWrapper.closure
    }
    set(newValue) {
      guard let newValue = newValue else { return }
      objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, UIBarButtonItemClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  convenience init(title: String?, style: UIBarButtonItem.Style, closure: @escaping UIBarButtonItemTargetClosure) {
    self.init(title: title, style: style, target: nil, action: nil)
    targetClosure = closure
    target = self
    action = #selector(closureAction)
  }

  @objc func closureAction() {
    guard let targetClosure = targetClosure else { return }
    targetClosure(self)
  }
}
