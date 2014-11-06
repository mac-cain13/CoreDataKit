//
//  CoreDataStack.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 15-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

public class CoreDataStack: NSObject {
    /// Persistent store coordinator used as backing for the contexts
    public let persistentStoreCoordinator: NSPersistentStoreCoordinator

    /// Root context that is directly associated with the `persistentStoreCoordinator` and does it work on a background queue
    public let rootContext: NSManagedObjectContext

    /// Context with concurrency type `NSMainQueueConcurrencyType` for use on the main thread
    public let mainThreadContext: NSManagedObjectContext

    /**
    Create a stack based on the given `NSPersistentStoreCoordinator`.

    :param: persistentStoreCoordinator The coordinator that will be coordinate the persistent store of this stack
    */
    public init(persistentStoreCoordinator _persistentStoreCoordinator: NSPersistentStoreCoordinator) {
        persistentStoreCoordinator = _persistentStoreCoordinator

        rootContext = NSManagedObjectContext(persistentStoreCoordinator: persistentStoreCoordinator)
        rootContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        mainThreadContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, parentContext: rootContext)

        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rootContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: rootContext)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

// MARK: Convenience methods

    /**
    Creates a child context with the root context as parent and performs the given block on the created context.
    
    :param: block       Block that performs the changes on the given context that should be saved
    :param: completion  Completion block to run after changes are saved

    :see: NSManagedObjectContext.performBlock()
    */
    public func performBlockOnBackgroundContext(block: PerformBlock, completionHandler: PerformBlockCompletionHandler? = nil) {
        rootContext.createChildContext().performBlock(block, completionHandler: completionHandler)
    }

    /**
    Dumps some debug info about this stack to the console
    */
    public func dumpStack() {
        CoreDataKit.sharedLogger(.DEBUG, "Stores: \(persistentStoreCoordinator.persistentStores)")
        CoreDataKit.sharedLogger(.DEBUG, " - Store coordinator: \(persistentStoreCoordinator.debugDescription)")
        CoreDataKit.sharedLogger(.DEBUG, "  - Root context: \(rootContext.debugDescription)")
        CoreDataKit.sharedLogger(.DEBUG, "   - Main thread context: \(mainThreadContext.debugDescription)")
    }

// MARK: Notification observers

    func rootContextDidSave(notification: NSNotification) {
        if NSThread.isMainThread() {
            if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as NSSet? {
                for _object in updatedObjects {
                    let object = _object as NSManagedObject
                    mainThreadContext.objectWithID(object.objectID).willAccessValueForKey(nil)
                }
            }

            mainThreadContext.mergeChangesFromContextDidSaveNotification(notification)
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.rootContextDidSave(notification)
            }
        }
    }
}
