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
        mainThreadContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, parentContext: rootContext)
    }
}
