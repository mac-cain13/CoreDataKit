//
//  CoreDataKit.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 23-06-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

public enum LogLevel {
    case DEBUG
    case INFO
    case WARN
    case ERROR
}

public typealias Logger = (LogLevel, String) -> Void

/**
`CoreDataKit` helps with setup of the CoreData stack
*/
public class CoreDataKit : NSObject
{
    private struct Holder {
        static var sharedStack: CoreDataStack?
        static var sharedLogger: Logger = { _, message in println("[CoreDataKit] \(message)") }
    }

    /**
    Property to hold a shared instance of CoreDataKit, all the convenience class properties access and unwrap this shared instance. So make sure to set the shared instance before doing anything else.
    
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

    /// Root context that is directly associated with the `persistentStoreCoordinator` and does it work on a background queue of the shared stack
    public class var rootContext: NSManagedObjectContext {
        return sharedStack!.rootContext
    }

    /// Context with concurrency type `NSMainQueueConcurrencyType` for use on the main thread of the shared stack
    public class var mainThreadContext: NSManagedObjectContext {
        return sharedStack!.mainThreadContext
    }

    /**
    Creates a child context with the root context of the shared stack as parent and performs the given block on the created context.

    :param: block       Block that performs the changes on the given context that should be saved
    :param: completion  Completion block to run after changes are saved

    :see: NSManagedObjectContext.performBlock()
    */
    public class func performBlockOnBackgroundContext(block: PerformBlock, completionHandler: PerformBlockCompletionHandler? = nil) {
        sharedStack!.performBlockOnBackgroundContext(block, completionHandler: completionHandler)
    }
}
