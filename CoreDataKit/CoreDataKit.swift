//
//  CoreDataKit.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 23-06-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

/**
    Blocktype used to handle completion.

    :param: error The error that occurred or nil if operation was successful
*/
public typealias CompletionHandler = (NSError?) -> Void

public typealias PerformChangesBlock = (NSManagedObjectContext) -> Void

/**
    `CoreDataKit` helps with setup of the CoreData stack
*/
public class CoreDataKit : NSObject
{
    private struct DefaultCoordinator {
        static var instance: NSPersistentStoreCoordinator?
    }

    /**
    Persistent store coordinator that is used as default for all CoreDataKit actions, this is the only property you need to set to setup the full CoreData stack.

    :discussion: It is not supported to change the persistent store coordinator after the root and main thread contexts are created. This will result in unknown behaviour.
    */
    public class var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        get {
            return DefaultCoordinator.instance
        }

        set {
            DefaultCoordinator.instance = newValue
        }
    }

    /**
    Root context that is directly associated with the `persistentStoreCoordinator` and does it work on a background queue, is automatically created on first use.
    */
    public class var rootContext: NSManagedObjectContext {
        struct Singleton {
            static let instance = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType, persistentStoreCoordinator: CoreDataKit.persistentStoreCoordinator!)
        }

        return Singleton.instance
    }

    /**
    Context with concurrency type `NSMainQueueConcurrencyType` for use on the main thread, is automatically created on first use and has `rootContext` set as it's parent context.
    */
    public class var mainThreadContext: NSManagedObjectContext {
        struct Singleton {
            static let instance = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, parentContext: CoreDataKit.rootContext)
        }

        return Singleton.instance
    }
}
