//
//  NSManagedObjectContext.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 24-06-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    convenience init(concurrencyType: NSManagedObjectContextConcurrencyType, persistentStoreCoordinator: NSPersistentStoreCoordinator)
    {
        self.init(concurrencyType: concurrencyType)
        self.performBlockAndWait { [unowned self] in
            self.persistentStoreCoordinator = persistentStoreCoordinator
        }
        self.beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
    }

    convenience init(concurrencyType: NSManagedObjectContextConcurrencyType, parentContext: NSManagedObjectContext)
    {
        self.init(concurrencyType: concurrencyType)
        self.performBlockAndWait { [unowned self] in
            self.parentContext = parentContext;
        }
        self.beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
    }

    func beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
    {
        // Make sure permanent IDs are obtained before saving
        // We can't send a message to ourselfs when we're deallocated so it's save, but not the nicest way.
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextWillSaveNotification, object: self, queue: NSOperationQueue.mainQueue()) { [unowned self] _ in
            self.obtainPermanentIDsForInsertedObjects()
        }
    }

    func obtainPermanentIDsForInsertedObjects()
    {
        if (self.insertedObjects.count > 0)
        {
            var possibleError: NSError?;
            self.obtainPermanentIDsForObjects(self.insertedObjects.allObjects, error: &possibleError)

            if let error = possibleError {
                // TODO: Handle error better
                println("CoreDataKit error while obtaining permanent IDs: \(error)")
            }
        }
    }
}
