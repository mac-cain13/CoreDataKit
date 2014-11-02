//
//  Observable.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 31-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

public class ManagedObjectObserver<T:NSManagedObject>: NSObject {
    typealias Subscriber = T -> Void

    public let observedObject: T
    var subscribers: [Subscriber]
    var notificationObserver: NSObjectProtocol?

    /**
    Start observing changes on a `NSManagedObject` in a certain context.
    
    :param: observeObject   Object to observe
    :param: inContext       Context to observe the object in
    */
    public init(observeObject observedObject: T, inContext context: NSManagedObjectContext) {
        // Try to convert the observee to the given context, may fail because it's not yet saved
        self.observedObject = context.find(observedObject).value() ?? observedObject

        self.subscribers = [Subscriber]()
        super.init()

        notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: context, queue: NSOperationQueue.mainQueue()) { notification in

            if self.subscribers.isEmpty {
                return
            }

            if let convertedObject = context.find(observedObject).value() {
                let changedObjects = NSMutableSet()

                if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? NSSet {
                    changedObjects.unionSet(updatedObjects)
                }

                if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? NSSet {
                    changedObjects.unionSet(insertedObjects)
                }

                if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? NSSet {
                    changedObjects.unionSet(deletedObjects)
                }

                if changedObjects.containsObject(convertedObject) {
                    for subscriber in self.subscribers {
                        subscriber(convertedObject)
                    }
                }
            }
        }
    }

    deinit {
        if let observer = notificationObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }

    /**
    Subscribe a block that gets called when the observed object changes
    
    :param: changeHandler The handler to call on change
    
    :returns: Token you can use to unsubscribe
    */
    public func subscribe(subscriber: Subscriber) -> Int {
        subscribers.append(subscriber)
        return subscribers.count - 1
    }

    /**
    Unsubscribe a previously subscribed block
    
    :param: token The token obtained when subscribing
    */
    public func unsubscribe(token: Int) {
        subscribers[token] = { _ in }
    }
}
