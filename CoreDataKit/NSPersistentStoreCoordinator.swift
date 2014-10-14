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
    class func coordinatorWithPersistentStore(URL optionalURL: NSURL?, automigrating: Bool, managedObjectModel optionalManagedObjectModel: NSManagedObjectModel?, error: NSErrorPointer) -> NSPersistentStoreCoordinator?
    {
        var coordinator: NSPersistentStoreCoordinator?

        let _managedObjectModel = optionalManagedObjectModel ?? NSManagedObjectModel.mergedModelFromBundles(nil)
        let _URL = optionalURL ?? NSPersistentStore.URLForStoreName("CoreDataKit")

        switch ((_managedObjectModel, _URL)) {
            case let (.Some(managedObjectModel), .Some(URL)):
                coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
                coordinator?.addSQLitePersistentStoreWithURL(URL, automigrating: automigrating, error: error)

            default:
                break
        }

        return coordinator
    }

    class func coordinatorWithInMemoryStore(managedObjectModel optionalManagedObjectModel: NSManagedObjectModel?, error: NSErrorPointer) -> NSPersistentStoreCoordinator?
    {
        var coordinator: NSPersistentStoreCoordinator?

        if let managedObjectModel = optionalManagedObjectModel ?? NSManagedObjectModel(byMergingModels: nil)
        {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            coordinator?.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: error)
        }

        return coordinator;
    }

    func addSQLitePersistentStoreWithURL(url: NSURL, automigrating: Bool, error: NSErrorPointer)
    {
        let addStore: () -> Void = {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: automigrating,
                NSInferMappingModelAutomaticallyOption: automigrating,
                NSSQLitePragmasOption: ["journal_mode": "WAL"]
            ];

            self.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: error)
        }

        addStore()

        // Workaround for "Migration failed after first pass" error
        if (automigrating && 0 == self.persistentStores.count)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) / 2), dispatch_get_main_queue(), addStore)
        }
    }
}
