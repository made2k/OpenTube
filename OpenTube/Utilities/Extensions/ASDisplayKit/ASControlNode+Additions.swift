
import AsyncDisplayKit

extension ASControlNode {
  
  struct AssociatedKeys {
    static var tapAction: UInt8 = 0
  }
  
  var tapAction: (() -> Void)? {
    get {
      guard let value = objc_getAssociatedObject(self, &AssociatedKeys.tapAction) as? (() -> Void) else { return nil }
      return value
    }
    set(newValue) {
      objc_setAssociatedObject(self, &AssociatedKeys.tapAction, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      addTarget(self, action: #selector(wasTapped), forControlEvents: .touchUpInside)
    }
  }
  
  @objc private func wasTapped() {
    tapAction?()
  }
}

