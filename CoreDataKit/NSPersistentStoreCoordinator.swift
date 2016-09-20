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
  public convenience init?(automigrating: Bool, deleteOnMismatch: Bool = false, URL optionalURL: URL? = nil, managedObjectModel optionalManagedObjectModel: NSManagedObjectModel? = nil) {

    // Fallback on the defaults
    let _managedObjectModel = optionalManagedObjectModel ?? NSManagedObjectModel.mergedModel(from: nil)
    let _url = optionalURL ?? NSPersistentStore.url(forSQLiteStoreName: "CoreDataKit")

    // Initialize coordinator if we have all data
    if let managedObjectModel = _managedObjectModel, let url = _url {
      self.init(managedObjectModel: managedObjectModel)
      self.addSQLitePersistentStore(at: url, automigrating: automigrating, deleteOnMismatch: deleteOnMismatch)
    }
    else {
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
    let _managedObjectModel = optionalManagedObjectModel ?? NSManagedObjectModel.mergedModel(from: nil)

    // Initialize coordinator if we have all data
    if let managedObjectModel = _managedObjectModel
    {
      self.init(managedObjectModel: managedObjectModel)
      do {
        try self.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
      } catch let error as NSError {
        throw error
      }
    }
    else
    {
      throw CoreDataKitError.unknownError(description: "NSMangedObjectModel should be available")
    }
  }

  // MARK: - Store add helpers

  /**
  Adds a SQLite persistent store to this persistent store coordinator.

  :discussion: Will do a async retry when automigration fails, because of a CoreData bug in serveral iOS versions where migration fails the first time.

  - parameter URL:           Location of the store
  - parameter automigrating: Whether the store should automigrate itself
  */
  fileprivate func addSQLitePersistentStore(at url: Foundation.URL, automigrating: Bool, deleteOnMismatch: Bool)
  {
    func addStore() throws {
      let options: [AnyHashable: Any] = [
        NSMigratePersistentStoresAutomaticallyOption: automigrating,
        NSInferMappingModelAutomaticallyOption: automigrating,
        NSSQLitePragmasOption: ["journal_mode": "WAL"]
      ];

      do {
        try self.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
      }
      catch {
        throw CoreDataKitError.coreDataError(error)
      }
    }

    do {
      try addStore()
    }
    catch let error as NSError {
      // Check for version mismatch
      if (deleteOnMismatch && NSCocoaErrorDomain == error.domain && (NSPersistentStoreIncompatibleVersionHashError == error.code || NSMigrationMissingSourceModelError == error.code)) {

        CDK.sharedLogger(.warn, "Model mismatch, removing persistent store...")
        let urlString = url.absoluteString
        let shmFile = urlString + "-shm"
        let walFile = urlString + "-wal"

        do {
          try FileManager.default.removeItem(at: url)
          try FileManager.default.removeItem(atPath: shmFile)
          try FileManager.default.removeItem(atPath: walFile)
        } catch _ {
        }

        do {
          try addStore()
        }
        catch let error {
          CDK.sharedLogger(.error, "Failed to add SQLite persistent store: \(error)")
        }
      }
        // Workaround for "Migration failed after first pass" error
      else if automigrating {
        CDK.sharedLogger(.warn, "[CoreDataKit] Applying workaround for 'Migration failed after first pass' bug, retrying...")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC) / 2) / Double(NSEC_PER_SEC)) {
          do {
            try addStore()
          }
          catch let error {
            CDK.sharedLogger(.error, "Failed to add SQLite persistent store: \(error)")
          }
        }
      }
      else {
        CDK.sharedLogger(.error, "Failed to add SQLite persistent store: \(error)")
      }
    }
  }
}
