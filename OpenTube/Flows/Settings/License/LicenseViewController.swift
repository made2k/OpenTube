import UIKit
import AsyncDisplayKit
import SafariServices

class LicenseViewController: ASViewController<ASTableNode>, ASTableDelegate, ASTableDataSource {

  let datasource: [(String, URL?)] = [
    ("Alamofire", URL(string: "https://github.com/Alamofire/Alamofire")),
    ("FFCircularProgressView", URL(string: "https://github.com/elbryan/FFCircularProgressView")),
    ("Icons8", URL(string: "https://icons8.com/")),
    ("MBProgressHUD", URL(string: "https://github.com/jdg/MBProgressHUD")),
    ("PromiseKit", URL(string: "https://github.com/mxcl/PromiseKit")),
    ("RealmSwift", URL(string: "https://realm.io/")),
    ("RxOptional", URL(string: "https://github.com/RxSwiftCommunity/RxOptional")),
    ("RxSwift", URL(string: "https://github.com/ReactiveX/RxSwift")),
    ("R.swift", URL(string: "https://github.com/mac-cain13/R.swift")),
    ("SnapKit", URL(string: "https://github.com/SnapKit/SnapKit")),
    ("SwiftyXML", URL(string: "https://github.com/chenyunguiMilook/SwiftyXML")),
    ("Texture", URL(string: "https://github.com/TextureGroup/Texture")),
    ("Then", URL(string: "https://github.com/devxoul/Then")),
    ("XCDYouTubeKit", URL(string: "https://github.com/0xced/XCDYouTubeKit"))
  ]
  
  init() {
    let table = ASTableNode(style: .plain)
    super.init(node: table)
    
    table.delegate = self
    table.dataSource = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    node.view.hideEmptyCells()
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return datasource.count
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    let node = ASTextCellNode()
    node.backgroundColor = .white
    node.text = datasource[indexPath.row].0
    return node
  }
  
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    guard let url = datasource[indexPath.row].1 else { return }
    let safari = SFSafariViewController(url: url)
    present(safari, animated: true, completion: nil)
  }

}
