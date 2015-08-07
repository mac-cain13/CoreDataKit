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
    
    - parameter automigrating:      Whether to enable automigration for the SQLite store
    - parameter URL:                URL to save the SQLite store at, pass nil to use default
    - parameter managedObjectModel: Managed object model to initialize the store with, pass nil to use all models in the main bundle
    */
    public convenience init?(automigrating: Bool, deleteOnMismatch: Bool = false, URL optionalURL: NSURL? = nil, managedObjectModel optionalManagedObjectModel: NSManagedObjectModel? = nil) {

        // Fallback on the defaults
        let _managedObjectModel = optionalManagedObjectModel ?? NSManagedObjectModel.mergedModelFromBundles(nil)
        let _URL = optionalURL ?? NSPersistentStore.URLForSQLiteStoreName("CoreDataKit")

        // Initialize coordinator if we have all data
        switch (_managedObjectModel, _URL) {
        case let (.Some(managedObjectModel), .Some(URL)):
            self.init(managedObjectModel: managedObjectModel)
            self.addSQLitePersistentStoreWithURL(URL, automigrating: automigrating, deleteOnMismatch: deleteOnMismatch)

        default:
            self.init()
            return nil
        }
    }

    /**
    Creates a `NSPersistentStoreCoordinator` with in memory store as backing store.

    - parameter managedObjectModel: Managed object model to initialize the store with, pass nil to use all models in the main bundle
    */
    public convenience init(managedObjectModel optionalManagedObjectModel: NSManagedObjectModel?) throws {
        // Fallback on the defaults
        let _managedObjectModel = optionalManagedObjectModel ?? NSManagedObjectModel.mergedModelFromBundles(nil)

        // Initialize coordinator if we have all data
        if let managedObjectModel = _managedObjectModel
        {
            self.init(managedObjectModel: managedObjectModel)
            do {
                try self.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
            } catch let error as NSError {
                throw error
            }
        }
        else
        {
            throw NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnknownError.rawValue, userInfo: nil)
        }
    }

// MARK: - Store add helpers

    /**
    Adds a SQLite persistent store to this persistent store coordinator.
    
    :discussion: Will do a async retry when automigration fails, because of a CoreData bug in serveral iOS versions where migration fails the first time.
    
    - parameter URL:           Location of the store
    - parameter automigrating: Whether the store should automigrate itself
    */
    private func addSQLitePersistentStoreWithURL(URL: NSURL, automigrating: Bool, deleteOnMismatch: Bool)
    {
        func addStore() throws {
            let options: [NSObject: AnyObject] = [
                NSMigratePersistentStoresAutomaticallyOption: automigrating,
                NSInferMappingModelAutomaticallyOption: automigrating,
                NSSQLitePragmasOption: ["journal_mode": "WAL"]
            ];

            try self.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: URL, options: options)
        }

        do {
            try addStore()
        }
        catch let error as NSError {
            // Check for version mismatch
            if (deleteOnMismatch && NSCocoaErrorDomain == error.domain && (NSPersistentStoreIncompatibleVersionHashError == error.code || NSMigrationMissingSourceModelError == error.code)) {

                CDK.sharedLogger(.WARN, "Model mismatch, removing persistent store...")
                let urlString = URL.absoluteString
                let shmFile = urlString.stringByAppendingString("-shm")
                let walFile = urlString.stringByAppendingString("-wal")

                do {
                    try NSFileManager.defaultManager().removeItemAtURL(URL)
                    try NSFileManager.defaultManager().removeItemAtPath(shmFile)
                    try NSFileManager.defaultManager().removeItemAtPath(walFile)
                } catch _ {
                }

                do {
                    try addStore()
                }
                catch let error {
                    CDK.sharedLogger(.ERROR, "Failed to add SQLite persistent store: \(error)")
                }
            }
            // Workaround for "Migration failed after first pass" error
            else if automigrating {
                CDK.sharedLogger(.WARN, "[CoreDataKit] Applying workaround for 'Migration failed after first pass' bug, retrying...")
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) / 2), dispatch_get_main_queue()) {
                    do {
                        try addStore()
                    }
                    catch let error {
                        CDK.sharedLogger(.ERROR, "Failed to add SQLite persistent store: \(error)")
                    }
                }
            }
            else {
                CDK.sharedLogger(.ERROR, "Failed to add SQLite persistent store: \(error)")
            }
        }
    }
}
