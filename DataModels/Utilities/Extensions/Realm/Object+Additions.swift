
import RealmSwift

extension Object {

  var safeRealm: Realm? {
    if let realm = self.realm {
      return realm
    }

    return try? Realm()
  }

  func saveObject() throws {
    try safeRealm?.write {
      safeRealm?.add(self)
    }
  }

  func removeObject() throws {
    try safeRealm?.write {
      safeRealm?.delete(self)
    }
  }

}


