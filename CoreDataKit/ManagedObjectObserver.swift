//
//  Observable.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 31-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

public enum ObservedAction<T:NSManagedObject> {
    case Updated(T)
    case Refreshed(T)
    case Inserted(T)
    case Deleted

    public func value() -> T? {
        switch self {
        case let .Updated(val):
            return val
        case let .Refreshed(val):
            return val
        case let .Inserted(val):
            return val

        case .Deleted:
            return nil
        }
    }
}

public class ManagedObjectObserver<T:NSManagedObject>: NSObject {
    public typealias Subscriber = ObservedAction<T> -> Void

    public let observedObject: T
    let context: NSManagedObjectContext
    var notificationObserver: NSObjectProtocol?
    var subscribers: [Subscriber]

    /**
    Start observing changes on a `NSManagedObject` in a certain context.
    
    - parameter observeObject:   Object to observe
    - parameter inContext:       Context to observe the object in
    */
    public init(observeObject _observedObject: T, inContext context: NSManagedObjectContext) {
        // Try to convert the observee to the given context, may fail because it's not yet saved
        do {
            self.observedObject = try context.find(T.self, managedObjectID: _observedObject.objectID)
        }
        catch {
            self.observedObject = _observedObject
        }

        self.context = context
        self.subscribers = [Subscriber]()
        super.init()

      notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: context, queue: nil) { [unowned self] notification in
        context.performBlock {
          if self.subscribers.isEmpty {
            return
          }

          do {
            let convertedObject = try context.find(T.self, managedObjectID: self.observedObject.objectID)
            if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? NSSet {
              if updatedObjects.containsObject(convertedObject) {
                self.notifySubscribers(.Updated(convertedObject))
              }
            }

            if let refreshedObjects = notification.userInfo?[NSRefreshedObjectsKey] as? NSSet {
              if refreshedObjects.containsObject(convertedObject) {
                self.notifySubscribers(.Refreshed(convertedObject))
              }
            }

            if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? NSSet {
              if insertedObjects.containsObject(convertedObject) {
                self.notifySubscribers(.Inserted(convertedObject))
              }
            }

            if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? NSSet {
              if deletedObjects.containsObject(convertedObject) {
                self.notifySubscribers(.Deleted)
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
            NSNotificationCenter.defaultCenter().removeObserver(notificationObserver)
        }
    }

    private func notifySubscribers(action: ObservedAction<T>) {
        for subscriber in self.subscribers {
            subscriber(action)
        }
    }

    /**
    Subscribe a block that gets called when the observed object changes
    
    - parameter changeHandler: The handler to call on change
    
    - returns: Token you can use to unsubscribe
    */
    public func subscribe(subscriber: Subscriber) -> Int {
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
}
