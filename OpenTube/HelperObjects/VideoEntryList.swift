import UIKit
import PromiseKit
import RealmSwift

class VideoEntryList: NSObject {
  
  let channelIds: [String]
  let realm = try! Realm()
  
  private(set) var videoEntries: [EntryObject] = []
  
  init(with channelIds: [String]?) {
    if let channels = channelIds {
      self.channelIds = channels
      
    } else {
      self.channelIds = realm.objects(SubscribedChannel.self).map { $0.channelId }
    }
  }

  func reloadEntries() -> Promise<Void> {
    videoEntries.removeAll()
    loadSavedEntries()
    
    return firstly {
     fetchNewEntries()
    }.done {
      self.videoEntries.append(contentsOf: $0)
      
    }.done {
      self.videoEntries = self.videoEntries.sorted(by: { first, second -> Bool in
        return first.publishDate > second.publishDate
      })
    }
    
  }
  
  func fetchNewEntries() -> Promise<[EntryObject]> {
    return firstly {
      Network.shared.getNewEntries(channelIds)
      
    }.filterValues {
      self.realm.objects(EntryObject.self).filter("videoId == %@", $0.videoId).isEmpty
      
    }.map { entries -> [EntryObject] in
      entries.map { EntryObject(entry: $0) }
      
    }.get { entries in
      try? self.realm.write {
        self.realm.add(entries)
      }
    }
  }
  
  func hideVideo(at index: Int) {
    let entry = videoEntries.remove(at: index)
    try? entry.realm?.write {
      entry.hidden = true
    }
  }
  
  // Note that deleting a video, it will reappear if the RSS
  // feed still contains that entry
  func deleteVideo(at index: Int) {
    let entry = videoEntries.remove(at: index)
    try? entry.realm?.write {
      entry.realm?.delete(entry)
    }
  }
  
  private func loadSavedEntries() {
    let results = realm.objects(EntryObject.self).filter("channelId IN %@ AND hidden == %@", channelIds, false).sorted(byKeyPath: "publishDate").reversed()
    videoEntries = Array(results)
  }
  
}
