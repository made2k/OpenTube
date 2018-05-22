import UIKit
import AsyncDisplayKit
import RealmSwift

class SubscribtionListViewController: ASViewController<ASTableNode> {
  private var datasource: [SubscribedChannel] = []
  let realm = try! Realm()
  
  init() {
    let node = ASTableNode(style: .plain)
    super.init(node: node)
    node.dataSource = self
    node.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    datasource = Array(realm.objects(SubscribedChannel.self).sorted(byKeyPath: "name"))
    node.reloadData()
  }
}

extension SubscribtionListViewController: ASTableDataSource {
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return datasource.count
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    return SubscribedCellNode(channel: datasource[indexPath.row])
  }
  
}

extension SubscribtionListViewController: ASTableDelegate {
  
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    guard let nav = navigationController else { return }
    
    let entry = datasource[indexPath.row]
    let vc = VideoListViewController(channelIds: [entry.channelId])
    
    nav.viewControllers.insert(vc, at: nav.viewControllers.count - 1)
    nav.popViewController(animated: true)
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .delete
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    let subscribed = datasource[indexPath.row]
    let entriesToRemove = realm.objects(EntryObject.self).filter("channelId == %@", subscribed.channelId)
    
    try! realm.write {
      realm.delete(subscribed)
      realm.delete(entriesToRemove)
    }
    
    NotificationCenter.default.post(name: Notifications.subscriptionListDidChange, object: nil)
    
    datasource.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }
}

class SubscribedCellNode: ASCellNode {
  let imageNode = ASNetworkImageNode()
  let titleNode = ASTextNode()
  let notificatonNode = ASButtonNode()
  
  let channel: SubscribedChannel
  
  init(channel: SubscribedChannel) {
    self.channel = channel
    super.init()
    automaticallyManagesSubnodes = true
    
    if let thumbnail = channel.channelThumbnailString {
      imageNode.url = URL(string: thumbnail)
    }
    imageNode.style.preferredSize = CGSize(width: 40, height: 40)
    imageNode.cornerRadius = 20
    
    let image = channel.notificationsEnabled ? #imageLiteral(resourceName: "ic_notification_enabled") : #imageLiteral(resourceName: "ic_notification_disabled")
    notificatonNode.setImage(image, for: .normal)
    notificatonNode.style.preferredSize = CGSize(width: 32, height: 32)
    notificatonNode.addTarget(self, action: #selector(notificationButtonPressed(sender:)), forControlEvents: .touchUpInside)
    
    titleNode.attributedText = NSAttributedString(string: channel.name ?? "")
    titleNode.style.flexGrow = 1
  }
  
  @objc func notificationButtonPressed(sender: ASButtonNode) {
    try? channel.realm?.write {
      channel.notificationsEnabled = !channel.notificationsEnabled
    }
    
    let image = channel.notificationsEnabled ? #imageLiteral(resourceName: "ic_notification_enabled") : #imageLiteral(resourceName: "ic_notification_disabled")
    notificatonNode.setImage(image, for: .normal)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.verticalAlignment = .center
    horizontal.spacing = 8
    horizontal.children = [imageNode, titleNode, notificatonNode]
    
    inset.child = horizontal
    
    return inset
  }
  
}
