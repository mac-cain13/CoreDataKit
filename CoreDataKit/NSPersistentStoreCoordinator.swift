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
    /**
    Creates a `NSPersistentStoreCoordinator` with SQLite added as persistent store.
    
    :discussion: Use `NSPersistentStore.URLForSQLiteStoreName(storeName:)` to create the store URL
    
    :param: automigrating      Whether to enable automigration for the SQLite store
    :param: URL                URL to save the SQLite store at, pass nil to use default
    :param: managedObjectModel Managed object model to initialize the store with, pass nil to use all models in the main bundle
    */
    public convenience init?(automigrating: Bool, URL optionalURL: NSURL? = nil, managedObjectModel optionalManagedObjectModel: NSManagedObjectModel? = nil) {

        // Fallback on the defaults
        let _managedObjectModel = optionalManagedObjectModel ?? NSManagedObjectModel.mergedModelFromBundles(nil)
        let _URL = optionalURL ?? NSPersistentStore.URLForSQLiteStoreName("CoreDataKit")

        // Initialize coordinator if we have all data
        switch ((_managedObjectModel, _URL)) {
        case let (.Some(managedObjectModel), .Some(URL)):
            self.init(managedObjectModel: managedObjectModel)
            self.addSQLitePersistentStoreWithURL(URL, automigrating: automigrating)

        default:
            self.init()
            return nil
        }
    }

    /**
    Creates a `NSPersistentStoreCoordinator` with in memory store as backing store.

    :param: managedObjectModel Managed object model to initialize the store with, pass nil to use all models in the main bundle
    :param: error              When the initializer fails this will contain error information
    */
    public convenience init?(managedObjectModel optionalManagedObjectModel: NSManagedObjectModel?, error: NSErrorPointer) {
        // Fallback on the defaults
        let _managedObjectModel = optionalManagedObjectModel ?? NSManagedObjectModel.mergedModelFromBundles(nil)

        // Initialize coordinator if we have all data
        if let managedObjectModel = _managedObjectModel
        {
            self.init(managedObjectModel: managedObjectModel)
            self.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: error)
        }
        else
        {
            self.init()
            return nil
        }
    }

// MARK: - Store add helpers

    /**
    Adds a SQLite persistent store to this persistent store coordinator.
    
    :discussion: Will do a async retry when automigration fails, because of a CoreData bug in serveral iOS versions where migration fails the first time.
    
    :param: URL           Location of the store
    :param: automigrating Whether the store should automigrate itself
    */
    func addSQLitePersistentStoreWithURL(URL: NSURL, automigrating: Bool)
    {
        let addStore: () -> Void = {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: automigrating,
                NSInferMappingModelAutomaticallyOption: automigrating,
                NSSQLitePragmasOption: ["journal_mode": "WAL"]
            ];

            var optionalError: NSError?
            self.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: URL, options: options, error: &optionalError)

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
