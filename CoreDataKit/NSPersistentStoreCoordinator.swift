//
//  NSPersistentStoreCoordinator.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 03-07-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSPersistentStoreCoordinator
{
    public class func coordinatorWithPersistentStore(URL optionalURL: NSURL?, automigrating: Bool, managedObjectModel optionalManagedObjectModel: NSManagedObjectModel?) -> NSPersistentStoreCoordinator?
    {
        var coordinator: NSPersistentStoreCoordinator?

        // Fallback on the defaults
        let _managedObjectModel = optionalManagedObjectModel ?? NSManagedObjectModel.mergedModelFromBundles(nil)
        let _URL = optionalURL ?? NSPersistentStore.URLForStoreName("CoreDataKit")

        // Initialize coordinator if we have all data
        switch ((_managedObjectModel, _URL)) {
            case let (.Some(managedObjectModel), .Some(URL)):
                coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
                coordinator?.addSQLitePersistentStoreWithURL(URL, automigrating: automigrating)

            default:
                break
        }

        return coordinator
    }

    public class func coordinatorWithInMemoryStore(managedObjectModel optionalManagedObjectModel: NSManagedObjectModel?, error: NSErrorPointer) -> NSPersistentStoreCoordinator?
    {
        var coordinator: NSPersistentStoreCoordinator?

        // Fallback on the defaults
        let _managedObjectModel = optionalManagedObjectModel ?? NSManagedObjectModel.mergedModelFromBundles(nil)

        // Initialize coordinator if we have all data
        if let managedObjectModel = _managedObjectModel
        {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            coordinator?.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: error)
        }

        return coordinator;
    }

// MARK: - Store add helpers

    func addSQLitePersistentStoreWithURL(url: NSURL, automigrating: Bool)
    {
        let addStore: () -> Void = {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: automigrating,
                NSInferMappingModelAutomaticallyOption: automigrating,
                NSSQLitePragmasOption: ["journal_mode": "WAL"]
            ];

            var optionalError: NSError?
            self.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: &optionalError)

            if let error = optionalError {
                println("[CoreDataKit] Error while adding SQLite persistent store: \(error)")
            }
        }

        addStore()

        // Workaround for "Migration failed after first pass" error
        if (automigrating && 0 == self.persistentStores.count)
        {
            println("[CoreDataKit] Applying workaround for 'Migration failed after first pass' bug, retrying...")
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) / 2), dispatch_get_main_queue(), addStore)
        }
    }
}
