
import AsyncDisplayKit
import Then

protocol SettingsViewControllerDelegate: class {
  func settingsDidSelectChannelList()
  func settingsDidSelectDownloads()
  func settingsDidSelectHidden()
  func settingsDidSelectAppSettings()
  func settingsDidSelectLicenses()
}

final class SettingsViewController: ASViewController<ASTableNode> {

  private weak var delegate: SettingsViewControllerDelegate?

  init(delegate: SettingsViewControllerDelegate) {

    self.delegate = delegate

    let table = ASTableNode(style: .grouped)
    table.backgroundColor = .white

    super.init(node: table)

    table.dataSource = self
    table.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

// MARK: - Navigation

extension SettingsViewController {

  func showSubscriptions() {
    delegate?.settingsDidSelectChannelList()
  }

  func showDoanloads() {
    delegate?.settingsDidSelectDownloads()
  }

  func showLicenses() {
    delegate?.settingsDidSelectLicenses()
  }

  func showSettings() {
    delegate?.settingsDidSelectAppSettings()
  }

  func showHidden() {
    delegate?.settingsDidSelectHidden()
  }

}

extension SettingsViewController: ASTableDataSource {

  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return TableViewSection.allCases.count
  }

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {

    switch section {
    case TableViewSection.media.rawValue: return MediaCellRows.allCases.count
    case TableViewSection.subscriptions.rawValue: return SubscriptionCellRows.allCases.count
    case TableViewSection.options.rawValue: return OptionCellRows.allCases.count
    default: return 0
    }

  }

  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    let node = ASTextCellNode().then {
      $0.backgroundColor = .white
    }

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

extension SettingsViewController: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    tableNode.deselectRow(at: indexPath, animated: true)

    if indexPath.section == TableViewSection.subscriptions.rawValue {
      switch indexPath.row {
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

private extension SettingsViewController {

  enum TableViewSection: Int, CaseIterable, CustomStringConvertible {
    case subscriptions
    case media
    case options

    var description: String {
      switch self {
      case .subscriptions: return "Channels"
      case .media: return "Media"
      case .options: return "Settings"
      }
    }
  }

  enum SubscriptionCellRows: Int, CaseIterable, CustomStringConvertible {
    case viewSubscriptions

    var description: String {
      switch self {
      case .viewSubscriptions: return "Channels"
      }
    }
  }

  enum MediaCellRows: Int, CaseIterable, CustomStringConvertible {
    case downloads
    case hidden

    var description: String {
      switch self {
      case .downloads: return "Downloads"
      case .hidden: return "Hidden"
      }
    }
  }

  enum OptionCellRows: Int, CaseIterable, CustomStringConvertible {
    case settings
    case licenses

    var description: String {
      switch self {
      case .settings: return "App Settings"
      case .licenses: return "Licenses"
      }
    }
  }
}
