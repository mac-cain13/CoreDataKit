//
//  CoreDataKit.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 23-06-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

/**
`CoreDataKit` helps with setup of the CoreData stack
*/
public class CoreDataKit : NSObject
{
    private struct Holder {
        static var sharedStack: CoreDataStack?
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
}
