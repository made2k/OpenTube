
import Alamofire
import Foundation
import PromiseKit
import RealmSwift
import RxCocoa

public enum SubscriptionError: Error {
  case alreadySubscribed
  case channelNotFound
}

/**
 This model is responsible for the users saved channels.
 You can think of it as a users subscriptions.
 */
public final class ChannelListModel: NSObject {

  public static let shared = ChannelListModel()

  public let subscriptions: BehaviorRelay<[ChannelModel]>

  private let realm = try! Realm()

  // MARK: - Initialization

  private override init() {
    let persistedObjects = realm.objects(ChannelPersistedObject.self)
    let models = persistedObjects.map { ChannelModel(persisted: $0) }.sorted()
    self.subscriptions = BehaviorRelay<[ChannelModel]>(value: models)
  }

  // MARK: - Subscription Management

  /**
   Adds a subscription based on the Channel ID

   - Parameter channelId: The channel ID of the channel to subscribe to.
   - Returns: A promise once the lookup and subscription has finished.
   The promise will resolve to a `SubscriptionError.alreadySubscribed` if
   the channel is already part of the users subscritions.
   */
  public func addSubscription(channelId: String) -> Promise<Void> {

    // Make sure we're not already subscribed to this channel
    guard realm.objects(ChannelPersistedObject.self).filter("channelId == %@", channelId).isEmpty else {
      return Promise(error: SubscriptionError.alreadySubscribed)
    }

    let q = DispatchQueue.global()
    let realmQ = DispatchQueue.main

    return firstly {
      fetchHTMLData(for: channelId)

    }.map(on: realmQ) { responseString -> ChannelModel in
      if let model = self.parseResponse(channelId: channelId, responseString: responseString) {
        return model
      }
      throw SubscriptionError.channelNotFound

    }.get(on: realmQ) {
      $0.savePersisted()

    }.map(on: q) { newChannel -> [ChannelModel] in
      return (self.subscriptions.value + [newChannel]).sorted()

    }.done(on: q) { subscriptions in
      self.subscriptions.accept(subscriptions)
    }
  }

  /**
   Adds a subscription based on the channel name.

   - Parameter channelName: The name of the channel to subscribe to.
   - Returns: A promise that resolves once the channel look up is complete.
 */
  public func addSubscription(channelName: String) -> Promise<Void> {
    let q = DispatchQueue.main

    return firstly {
      getChannelId(for: channelName)

    }.then(on: q) { channelId -> Promise<Void> in
      self.addSubscription(channelId: channelId)
    }

  }

  /**
   Unsubscribes from a channel. Calling this will remove the
   channel from this persisted list. It will also clear all
   information about the videos associated with the channel.
   */
  public func removeSubscription(_ model: ChannelModel) {
    do {
      try model.deletePersisted()
      subscriptions.accept(subscriptions.value.filter { $0 !== model })
    } catch {
      print("error deleting subscribed channel")
    }
  }

  // MARK: - Channel fetching

  /// Given a channel name, we need the ID for the RSS feed. This
  /// function will make the required calls to fetch the channel ID.
  private func getChannelId(for channelName: String) -> Promise<String> {

    guard let url = URL(string: "https://www.youtube.com/user/\(channelName)") else {
      return Promise(error: SubscriptionError.channelNotFound)
    }

    let q = DispatchQueue.global()

    return firstly {
      Alamofire.request(url).responseString()

    }.map(on: q) {
      return $0.string

    }.map(on: q) { responseString -> String in
      if let channelId = responseString.substring(after: "\"channelId\" content=\"", before: "\"") {
        return channelId
      }
      throw SubscriptionError.channelNotFound
    }

  }

  /// Fetch the HTML from YouTube for the channel
  private func fetchHTMLData(for channelId: String) -> Promise<String> {

    guard let url = URL(string: "https://www.youtube.com/channel/\(channelId)") else {
      return Promise(error: SubscriptionError.channelNotFound)
    }

    return Alamofire.request(url).responseString().map { $0.string }
  }

  private func parseResponse(channelId: String, responseString: String) -> ChannelModel? {
    guard let thumbnailString = responseString.substring(after: "<img class=\"appbar-nav-avatar\" src=\"", before: "\"") else { return nil }
    guard let thumbnailURL = URL(string: thumbnailString) else { return nil }
    guard let channelName = responseString.substring(after: "<meta property=\"og:title\" content=\"", before: "\"") else { return nil }

    return ChannelModel(channelId: channelId, channelName: channelName, thumbnail: thumbnailURL)
  }

}

fileprivate extension Array where Element: ChannelModel {

  func sorted() -> [ChannelModel] {
    return self.sorted(by: { $0.channelName.caseInsensitiveCompare($1.channelName) == .orderedAscending })
  }

}
