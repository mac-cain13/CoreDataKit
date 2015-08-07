//
//  CDK.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 23-06-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

public enum CDKLogLevel {
    case DEBUG
    case INFO
    case WARN
    case ERROR
}

public typealias Logger = (CDKLogLevel, String) -> Void

/**
`CDK` helps with setup of the CoreData stack
*/
public class CDK : NSObject
{
    private struct Holder {
        static var sharedStack: CoreDataStack?
        static var sharedLogger: Logger = { _, message in print("[CoreDataKit] \(message)") }
    }

    /**
    Property to hold a shared instance of CoreDataStack, all the convenience class properties access and unwrap this shared instance. So make sure to set the shared instance before doing anything else.
    
    :discussion: This is the only property you have to set to setup CoreDataKit, changing the shared instace is not supported.
    */
    public class var sharedStack: CoreDataStack? {
        get {
            return Holder.sharedStack
        }

        set {
            Holder.sharedStack = newValue
        }
    }

    /**
    Shared logger used by CoreDataKit to log messages.
    
    :discussion: Default logger prints messages to console, but you can use this to use your own logger
    */
    public class var sharedLogger: Logger {
        get {
            return Holder.sharedLogger
        }

        set {
            Holder.sharedLogger = newValue
        }
    }

// MARK: Convenience properties

    /// Persistent store coordinator used as backing for the contexts of the shared stack
    public class var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return sharedStack!.persistentStoreCoordinator
    }

    /// Child context of `rootContext` with concurrency type `PrivateQueueConcurrencyType`; Perform all read/write actions on this context
    public class var backgroundContext: NSManagedObjectContext {
        return sharedStack!.backgroundContext
    }

    /// Context with concurrency type `NSMainQueueConcurrencyType`; Use only for read actions directly tied to the UI (e.g. NSFetchedResultsController)
    public class var mainThreadContext: NSManagedObjectContext {
        return sharedStack!.mainThreadContext
    }

    /**
    Performs the given block on the `backgroundContect`

    - parameter block:       Block that performs the changes on the given context that should be saved
    - parameter completion:  Completion block to run after changes are saved

    :see: NSManagedObjectContext.performBlock()
    */
    public class func performBlockOnBackgroundContext(block: PerformBlock, completionHandler: PerformBlockCompletionHandler?) {
        sharedStack!.performBlockOnBackgroundContext(block, completionHandler: completionHandler)
    }

    public class func performBlockOnBackgroundContext(block: PerformBlock) {
        sharedStack!.performBlockOnBackgroundContext(block, completionHandler: nil)
    }
}
