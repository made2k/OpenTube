import UIKit
import AsyncDisplayKit
import SideMenu

class MenuViewController: ASViewController<ASTableNode> {
  
  init() {
    let table = ASTableNode(style: .grouped)
    super.init(node: table)
    table.dataSource = self
    table.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func showSubscriptions() {
    navigationController?.pushViewController(SubscribtionListViewController(), animated: true)
  }
  
  func showAddChannel() {
    let presenting = presentingViewController
    dismiss(animated: true) {
      let vc = UIStoryboard(name: "AddChannel", bundle: nil).instantiateInitialViewController()!
      presenting?.present(vc, animated: true, completion: nil)
    }
  }
  
  func showDoanloads() {
    navigationController?.pushViewController(DownloadListViewController(), animated: true)
  }
  
  func showLicenses() {
    navigationController?.pushViewController(LicenseViewController(), animated: true)
  }
  
  func showSettings() {
    let presenting = presentingViewController
    dismiss(animated: true) {
      let vc = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController()!
      presenting?.present(vc, animated: true, completion: nil)
    }
  }
  
  func showHidden() {
    navigationController?.pushViewController(HiddenViewController(), animated: true)
  }
  
}

extension MenuViewController: ASTableDataSource {
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return TableViewSection.count
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case TableViewSection.media.rawValue: return MediaCellRows.count
    case TableViewSection.subscriptions.rawValue: return SubscriptionCellRows.count
    case TableViewSection.options.rawValue: return OptionCellRows.count
    default: return 0
    }
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    let node = ASTextCellNode()
    
    if indexPath.section == TableViewSection.subscriptions.rawValue {
      node.text = SubscriptionCellRows(rawValue: indexPath.row)!.description
      
    } else if indexPath.section == TableViewSection.media.rawValue {
      node.text = MediaCellRows(rawValue: indexPath.row)!.description
      
    } else if indexPath.section == TableViewSection.options.rawValue {
      node.text = OptionCellRows(rawValue: indexPath.row)!.description
    }
    
    return node
  }
}

extension MenuViewController: ASTableDelegate {
  
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    tableNode.deselectRow(at: indexPath, animated: true)
    
    if indexPath.section == TableViewSection.subscriptions.rawValue {
      switch indexPath.row {
      case SubscriptionCellRows.addSubscription.rawValue:
        showAddChannel()
      case SubscriptionCellRows.viewSubscriptions.rawValue:
        showSubscriptions()
      default: return
      }
      
    } else if indexPath.section == TableViewSection.media.rawValue {
      switch indexPath.row {
      case MediaCellRows.downloads.rawValue:
        showDoanloads()
      case MediaCellRows.hidden.rawValue:
        showHidden()
      default: return
      }
      
      
    } else if indexPath.section == TableViewSection.options.rawValue {
      switch indexPath.row {
      case OptionCellRows.settings.rawValue:
        showSettings()
      case OptionCellRows.licenses.rawValue:
        showLicenses()
      default: return
      }
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return TableViewSection(rawValue: section)?.description
  }
  
}

private extension MenuViewController {
  
  enum TableViewSection: Int, CustomStringConvertible {
    case subscriptions
    case media
    case options
    
    static var count = 3
    
    var description: String {
      switch self {
      case .subscriptions: return "Channels"
      case .media: return "Media"
      case .options: return "Settings"
      }
    }
  }
  
  enum SubscriptionCellRows: Int, CustomStringConvertible {
    case addSubscription
    case viewSubscriptions
    
    static var count = 2
    
    var description: String {
      switch self {
      case .addSubscription: return "Add Channel"
      case .viewSubscriptions: return "Channels"
      }
    }
  }
  
  enum MediaCellRows: Int, CustomStringConvertible {
    case downloads
    case hidden
    
    static var count = 2
    
    var description: String {
      switch self {
      case .downloads: return "Downloads"
      case .hidden: return "Hidden"
      }
    }
  }
  
  enum OptionCellRows: Int, CustomStringConvertible {
    case settings
    case licenses
    
    static var count = 2
    
    var description: String {
      switch self {
      case .settings: return "App Settings"
      case .licenses: return "Licenses"
      }
    }
  }
}
