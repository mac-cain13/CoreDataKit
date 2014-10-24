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
}
