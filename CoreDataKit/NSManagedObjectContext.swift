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
