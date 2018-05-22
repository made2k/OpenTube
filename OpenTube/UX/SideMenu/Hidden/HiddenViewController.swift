import UIKit
import AsyncDisplayKit
import RealmSwift

class HiddenViewController: ASViewController<ASTableNode>, ASTableDelegate, ASTableDataSource {
  
  private var hiddenVideos: [EntryObject] = []
  
  init() {
    let table = ASTableNode(style: .plain)
    super.init(node: table)
    
    table.delegate = self
    table.dataSource = self
    
    let hidden = try! Realm().objects(EntryObject.self).filter("hidden == %@", true).sorted(byKeyPath: "publishDate").reversed()
    hiddenVideos = Array(hidden)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return hiddenVideos.count
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    let entry = hiddenVideos[indexPath.row]
    let node = DownloadCellNode(entry: entry)
    return node
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .delete
  }
  
  func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return "Unhide"
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    let entry = hiddenVideos.remove(at: indexPath.row)
    try! entry.realm?.write {
      entry.hidden = false
    }
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }

}
