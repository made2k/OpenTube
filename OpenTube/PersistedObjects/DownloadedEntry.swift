import UIKit
import RealmSwift

class DownloadedEntry: Object {
    
    @objc dynamic var remoteUrlString: String = ""
    @objc dynamic var fileName: String = ""
    
    @objc dynamic var videoEntry: EntryObject!
    
    var remoteUrl: URL {
        return URL(string: remoteUrlString)!
    }
    var localUrl: URL {
        return DownloadManager.mediaDirectory.appendingPathComponent(fileName)
    }
    
    convenience init(entry: EntryObject, remoteUrl: URL, fileName: String) {
        self.init()
        
        remoteUrlString = remoteUrl.absoluteString
        self.fileName = fileName
        videoEntry = entry
    }

}
