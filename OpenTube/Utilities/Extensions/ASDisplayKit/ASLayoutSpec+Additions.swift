
import AsyncDisplayKit

extension ASLayoutSpec {

  static func spacer() -> ASLayoutSpec {
    let spec = ASLayoutSpec()
    spec.style.flexGrow = 1
    return spec
  }

}
