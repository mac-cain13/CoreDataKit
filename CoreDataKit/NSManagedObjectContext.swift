//
//  NSManagedObjectContext.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 24-06-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSManagedObjectContext
{
    public convenience init(concurrencyType: NSManagedObjectContextConcurrencyType, persistentStoreCoordinator: NSPersistentStoreCoordinator)
    {
        self.init(concurrencyType: concurrencyType)
        self.performBlockAndWait { [unowned self] in
            self.persistentStoreCoordinator = persistentStoreCoordinator
        }
        self.beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
    }

    public convenience init(concurrencyType: NSManagedObjectContextConcurrencyType, parentContext: NSManagedObjectContext)
    {
        self.init(concurrencyType: concurrencyType)
        self.performBlockAndWait { [unowned self] in
            self.parentContext = parentContext;
        }
        self.beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
    }

// MARK: - Saving

    /**
    Performs the given block on a child context and persists changes performed on the given context to the persistent store. After saving the `CompletionHandler` block is called and passed a `NSError` object when an error occured or nil when saving was successfull. The `CompletionHandler` will always be called on the main thread.

    :discussion: Do not nest save operations with this method, since the nested save will also save to the persistent store this will give unexpected results.

    :discussion: Please remember that `NSManagedObjects` are not threadsafe and your block is performed on another thread/`NSManagedObjectContext`. Make sure to **always** convert your `NSManagedObjects` to the given `NSManagedObjectContext` with `NSManagedObject.inContext()` or by looking up the `NSManagedObjectID` in the given context. This prevents disappearing data, which in turn prevents hairpulling.

    :param: block       Block that performs the changes on the given context that should be saved
    :param: completion  Completion block to run after changes are saved
    */
    public func performBlockAndPersist(block: PerformChangesBlock, completion: CompletionHandler?) {
        let childContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType, parentContext: CoreDataKit.rootContext)

        childContext.performBlock {
            block(childContext)
            childContext.saveToPersistentStore(completion)
        }
    }

    /**
    Performs the given block on a background thread and persists changes performed on the `NSManagedObjectContext` given to the block to the persistent store.

    :param: saveBlock  Block that performs the changes on the given context that should be saved

    :see: performBlockAndPersist(block:completion:)
    */
    public func performBlockAndPersist(block: PerformChangesBlock) {
        performBlockAndPersist(block, completion: nil)
    }

    public func saveToPersistentStore(completionHandler optionalCompletionHandler: CompletionHandler?)
    {
        performBlock {
            var optionalError: NSError?
            self.save(&optionalError)

            switch (optionalError, self.parentContext, optionalCompletionHandler) {
                case let (.None, .Some(parentContext), _):
                    parentContext.saveToPersistentStore(optionalCompletionHandler)

                case let (_, _, .Some(completionHandler)):
                    dispatch_async(dispatch_get_main_queue()) { completionHandler(optionalError) }

                default:
                    break
            }
        }
    }

    public func saveToParentContext(completionHandler optionalCompletionHandler: CompletionHandler?)
    {
        performBlock {
            var optionalError: NSError?
            self.save(&optionalError)

            if let completionHandler = optionalCompletionHandler {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(optionalError) }
            }
        }
    }

// MARK: - Obtaining permanent IDs

    func beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
    {
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextWillSaveNotification, object: self, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            self?.obtainPermanentIDsForInsertedObjects(nil)
            return
        }
    }

    public func obtainPermanentIDsForInsertedObjects(error: NSErrorPointer)
    {
        if (self.insertedObjects.count > 0) {
            self.obtainPermanentIDsForObjects(self.insertedObjects.allObjects, error: error)
        }
    }
}
