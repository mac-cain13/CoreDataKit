//
//  Observable.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 31-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

public class ManagedObjectObserver<T:NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    public typealias ChangeHandler = T -> Void

    public let observedObject: T
    var subscriptions: [ChangeHandler]

    public init(observedObject: T, inContext context: NSManagedObjectContext) {
        self.observedObject = observedObject
        self.subscriptions = [ChangeHandler]()

        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "managedObjectContextObjectsDidChange:", name: NSManagedObjectContextObjectsDidChangeNotification, object: context)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    /**
    Subscribe a block that gets called when the observed object changes
    
    :param: changeHandler The handler to call on change
    
    :returns: Token you can use to unsubscribe
    */
    public func subscribe(changeHandler: ChangeHandler) -> Int {
        subscriptions.append(changeHandler)
        return subscriptions.count - 1
    }

    /**
    Unsubscribe a previously subscribed block
    
    :param: token The token obtained when subscribing
    */
    public func unsubscribe(token: Int) {
        subscriptions[token] = { _ in }
    }

// MARK: Notification listeners

    /// Notification listener
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
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

        if changedObjects.containsObject(observedObject) {
            for changeHandler in subscriptions {
                changeHandler(observedObject)
            }
        }
    }
}
