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

  /// Root context that is directly associated with the `persistentStoreCoordinator` and does it work on a background queue; Do not use directly
  public let rootContext: NSManagedObjectContext

  /// Context with concurrency type `NSMainQueueConcurrencyType`; Use only for read actions directly tied to the UI (e.g. NSFetchedResultsController)
  public let mainThreadContext: NSManagedObjectContext

  /// Child context of `rootContext` with concurrency type `PrivateQueueConcurrencyType`; Perform all read/write actions on this context
  public let backgroundContext: NSManagedObjectContext

  /**
  Create a stack based on the given `NSPersistentStoreCoordinator`.

  - parameter persistentStoreCoordinator: The coordinator that will be coordinate the persistent store of this stack
  */
  public init(persistentStoreCoordinator: NSPersistentStoreCoordinator) {
    self.persistentStoreCoordinator = persistentStoreCoordinator

    self.rootContext = NSManagedObjectContext(persistentStoreCoordinator: self.persistentStoreCoordinator)
    self.rootContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    self.mainThreadContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType, parentContext: rootContext)

    self.backgroundContext = self.mainThreadContext.createChildContext()

    super.init()

    // TODO: In de huidige setup, nobody cares, want main context zit tussen de saves in en krijgt vanzelf de notificaties
    //NSNotificationCenter.defaultCenter().addObserver(self, selector: "rootContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: rootContext)
  }

  //    deinit {
  //        NSNotificationCenter.defaultCenter().removeObserver(self)
  //    }

  // MARK: Convenience methods

  /**
  Performs the given block on the `backgroundContect`

  - parameter block:       Block that performs the changes on the given context that should be saved
  - parameter completion:  Completion block to run after changes are saved

  :see: NSManagedObjectContext.performBlock()
  */
  public func performOnBackgroundContext(block: @escaping PerformBlock, completionHandler: PerformBlockCompletionHandler?) {
    backgroundContext.perform(block: block, completionHandler: completionHandler)
  }

  @available(*, unavailable, renamed: "performOnBackgroundContext(block:completionHandler:)")
  public func performBlockOnBackgroundContext(_ block: PerformBlock, completionHandler: PerformBlockCompletionHandler?) {
    fatalError()
  }

  public func performOnBackgroundContext(block: @escaping PerformBlock) {
    backgroundContext.perform(block: block, completionHandler: nil)
  }

  @available(*, unavailable, renamed: "performOnBackgroundContext(block:)")
  public func performBlockOnBackgroundContext(_ block: PerformBlock) {
    fatalError()
  }

  /**
  Dumps some debug info about this stack to the console
  */
  public func dumpStack() {
    CDK.sharedLogger(.debug, "Stores: \(persistentStoreCoordinator.persistentStores)")
    CDK.sharedLogger(.debug, " - Store coordinator: \(persistentStoreCoordinator.debugDescription)")
    CDK.sharedLogger(.debug, "   |- Root context: \(rootContext.debugDescription)")
    CDK.sharedLogger(.debug, "      |- Main thread context: \(mainThreadContext.debugDescription)")
    CDK.sharedLogger(.debug, "         |- Background context: \(backgroundContext.debugDescription)")
  }

  // MARK: Notification observers

  //    func rootContextDidSave(notification: NSNotification) {
  //        if NSThread.isMainThread() {
  //            if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? NSSet {
  //                for _object in updatedObjects {
  //                    let object = _object as! NSManagedObject
  //                    mainThreadContext.objectWithID(object.objectID).willAccessValueForKey(nil)
  //                }
  //            }
  //
  //            mainThreadContext.mergeChangesFromContextDidSaveNotification(notification)
  //        } else {
  //            dispatch_async(dispatch_get_main_queue()) {
  //                self.rootContextDidSave(notification)
  //            }
  //        }
  //    }
}
