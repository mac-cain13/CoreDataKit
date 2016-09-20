//
//  Observable.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 31-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

public enum ObservedAction<T:NSManagedObject> {
  case updated(T)
  case refreshed(T)
  case inserted(T)
  case deleted

  public func value() -> T? {
    switch self {
    case let .updated(val):
      return val
    case let .refreshed(val):
      return val
    case let .inserted(val):
      return val

    case .deleted:
      return nil
    }
  }
}

public class ManagedObjectObserver<T:NSManagedObject>: NSObject {
  public typealias Subscriber = (ObservedAction<T>) -> Void

  public let observedObject: T
  let context: NSManagedObjectContext
  var notificationObserver: NSObjectProtocol?
  var subscribers: [Subscriber]

  /**
  Start observing changes on a `NSManagedObject` in a certain context.

  - parameter observeObject:   Object to observe
  - parameter inContext:       Context to observe the object in
  */
  public init(observeObject originalObserveObject: T, inContext context: NSManagedObjectContext) {
    // Try to convert the observee to the given context, may fail because it's not yet saved
    let observeObject = try? context.find(T.self, managedObjectID: originalObserveObject.objectID)
    self.observedObject = observeObject ?? originalObserveObject

    self.context = context
    self.subscribers = [Subscriber]()
    super.init()

    notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context, queue: nil) { [unowned self] notification in
      context.perform {
        if self.subscribers.isEmpty {
          return
        }

        do {
          let convertedObject = try context.find(T.self, managedObjectID: self.observedObject.objectID)
          if let updatedObjects = (notification as NSNotification).userInfo?[NSUpdatedObjectsKey] as? NSSet {
            if updatedObjects.contains(convertedObject) {
              self.notifySubscribers(.updated(convertedObject))
            }
          }

          if let refreshedObjects = (notification as NSNotification).userInfo?[NSRefreshedObjectsKey] as? NSSet {
            if refreshedObjects.contains(convertedObject) {
              self.notifySubscribers(.refreshed(convertedObject))
            }
          }

          if let insertedObjects = (notification as NSNotification).userInfo?[NSInsertedObjectsKey] as? NSSet {
            if insertedObjects.contains(convertedObject) {
              self.notifySubscribers(.inserted(convertedObject))
            }
          }

          if let deletedObjects = (notification as NSNotification).userInfo?[NSDeletedObjectsKey] as? NSSet {
            if deletedObjects.contains(convertedObject) {
              self.notifySubscribers(.deleted)
            }
          }
        }
        catch {
        }
      }
    }
  }

  deinit {
    if let notificationObserver = notificationObserver {
      NotificationCenter.default.removeObserver(notificationObserver)
    }
  }

  fileprivate func notifySubscribers(_ action: ObservedAction<T>) {
    for subscriber in self.subscribers {
      subscriber(action)
    }
  }

  /**
  Subscribe a block that gets called when the observed object changes

  - parameter changeHandler: The handler to call on change

  - returns: Token you can use to unsubscribe
  */
  public func subscribe(_ subscriber: @escaping Subscriber) -> Int {
    subscribers.append(subscriber)
    return subscribers.count - 1
  }

  /**
  Unsubscribe a previously subscribed block

  - parameter token: The token obtained when subscribing
  */
  public func unsubscribe(token: Int) {
    subscribers[token] = { _ in }
  }

  @available(*, unavailable, renamed: "unsubscribe(token:)")
  public func unsubscribe(_ token: Int) {
    fatalError()
  }
}
