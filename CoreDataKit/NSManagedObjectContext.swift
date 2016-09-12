//
//  NSManagedObjectContext.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 24-06-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSManagedObjectContext
{
  /**
  Create a new `NSManagedObjectContext` that is directly associated with the given `NSPersistentStoreCoordinator`, will be of type `NSPrivateQueueConcurrencyType`.

  :discussion: The context will also obtain permanent IDs for `NSManagedObject`s before saving. This will prevent problems where you can't convert objects between two `NSManagedObjectContext`s, so it's advised to create contexts using this method.

  - parameter persistentStoreCoordinator: Persistent store coordinator to associate with

  - returns: Managed object context
  */
  public convenience init(persistentStoreCoordinator: NSPersistentStoreCoordinator)
  {
    self.init(concurrencyType: .privateQueueConcurrencyType)
    performAndWait { [unowned self] in
      self.persistentStoreCoordinator = persistentStoreCoordinator
      self.undoManager = UndoManager()
    }
    // Moved the obtainPermanentIDsForInsertedObjects() call into the save methods itself to prevent deadlock scenarios
    // See commit 3bc30e1c59e395cf5b8b157842c24cc7e49a9edb
    //        beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
  }

  /**
  Create a new `NSManagedObjectContext` that has the given context set as parent context to save to.

  :discussion: The context will also obtain permanent IDs for `NSManagedObject`s before saving. This will prevent problems where you can't convert objects between two `NSManagedObjectContext`s, so it's advised to create context using this method.

  - parameter concurrencyType: Concurrency type to use, must be `NSPrivateQueueConcurrencyType` or `NSMainQueueConcurrencyType`
  - parameter parentContext: Parent context to associate with

  - returns: Managed object context
  */
  public convenience init(concurrencyType: NSManagedObjectContextConcurrencyType, parentContext: NSManagedObjectContext)
  {
    self.init(concurrencyType: concurrencyType)
    performAndWait { [unowned self] in
      self.parent = parentContext
      self.undoManager = UndoManager()
    }
    // Moved the obtainPermanentIDsForInsertedObjects() call into the save methods itself to prevent deadlock scenarios
    // See commit 3bc30e1c59e395cf5b8b157842c24cc7e49a9edb
    //        beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
  }

  /**
  Creates child context with this context as its parent

  - returns: Child context
  */
  public func createChildContext() -> NSManagedObjectContext {
    return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType, parentContext: self)
  }

  // MARK: - Saving

  /**
  Performs the given block on a child context and persists changes performed on the given context to the persistent store. After saving the `CompletionHandler` block is called and passed a `NSError` object when an error occured or nil when saving was successfull. The `CompletionHandler` will always be called on the thread the context performs it's operations on.

  :discussion: Do not nest save operations with this method, since the nested save will also save to the persistent store this will give unexpected results. Also the nested calls will not perform their changes on nested contexts, so the changes will not appear in the outer call as you'd expect to.

  :discussion: Please remember that `NSManagedObjects` are not threadsafe and your block is performed on another thread/`NSManagedObjectContext`. Make sure to **always** convert your `NSManagedObjects` to the given `NSManagedObjectContext` with `NSManagedObject.inContext()` or by looking up the `NSManagedObjectID` in the given context. This prevents disappearing data.

  - parameter block:       Block that performs the changes on the given context that should be saved
  - parameter completion:  Completion block to run after changes are saved
  */
  public func perform(block: @escaping PerformBlock, completionHandler: PerformBlockCompletionHandler? = nil) {
    perform {
      self.undoManager?.beginUndoGrouping()
      let commitAction = block(self)
      self.undoManager?.endUndoGrouping()

      switch commitAction {
      case .doNothing:
        completionHandler?({ commitAction })

      case .saveToParentContext:
        do {
          try self.obtainPermanentIDsForInsertedObjects()
          try self.save()
          completionHandler?({ commitAction })
        } catch {
          completionHandler?({ throw CoreDataKitError.coreDataError(error) })
        }

      case .saveToPersistentStore:
        self.saveToPersistentStore { arg in
          completionHandler?({ try arg(); return commitAction })
        }

      case .undo:
        self.undo()
        completionHandler?({ commitAction })

      case .rollbackAllChanges:
        self.rollback()
        completionHandler?({ commitAction })
      }
    }
  }

  @available(*, unavailable, renamed: "perform(block:completionHandler:)")
  public func performBlock(_ block: @escaping PerformBlock, completionHandler: PerformBlockCompletionHandler? = nil) {
  }

  /**
  Save all changes in this context and all parent contexts to the persistent store, `CompletionHandler` will be called when finished.

  :discussion: Must be called from a perform block action

  - parameter completionHandler:  Completion block to run after changes are saved
  */
  func saveToPersistentStore(_ completionHandler: CompletionHandler? = nil)
  {
    do {
      try obtainPermanentIDsForInsertedObjects()
      try save()

      if let parentContext = self.parent {
        parentContext.perform {
          parentContext.saveToPersistentStore(completionHandler)
        }
      }
      else {
        completionHandler?({})
      }
    } catch let error as NSError {
      completionHandler?({ throw error })
    }
  }

  // MARK: Obtaining permanent IDs

  /// Installs a notification handler on the will save event that calls `obtainPermanentIDsForInsertedObjects()`
  func beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
  {
    NotificationCenter.default.addObserver(self, selector: #selector(NSManagedObjectContext.obtainPermanentIDsForInsertedObjectsOnContextWillSave(_:)), name: NSNotification.Name.NSManagedObjectContextWillSave, object: self)
  }

  func obtainPermanentIDsForInsertedObjectsOnContextWillSave(_ notification: Notification)
  {
    do {
      try obtainPermanentIDsForInsertedObjects()
    }
    catch {
    }
  }

  /**
  Obtains permanent object IDs for all objects inserted in this context. This ensures that the object has an object ID that you can lookup in an other context.

  @discussion This method is called automatically by `NSManagedObjectContext`s that are created by CoreDataKit right before saving. So usually you don't have to use this yourself if you stay within CoreDataKit created contexts.
  */
  public func obtainPermanentIDsForInsertedObjects() throws {
    if (self.insertedObjects.count > 0) {
      do {
        try self.obtainPermanentIDs(for: Array(self.insertedObjects))
      }
      catch {
        throw CoreDataKitError.coreDataError(error)
      }
    }
  }

  // MARK: - Creating

  /**
  Create and insert an entity into this context

  - parameter entity: Type of entity to create

  - returns: Result with the created entity
  */
  public func create<T:NSManagedObject>(_ entity: T.Type) throws -> T where T:NamedManagedObject
  {
    let desc = try entityDescription(entity)
    return try self.create(desc)
  }

  /**
  Create and insert entity into this context based on its description

  - parameter entityDescription: Description of the entity to create

  - returns: Result with the created entity
  */
  func create<T:NSManagedObject>(_ entityDescription: NSEntityDescription) throws -> T
  {
    if let entityName = entityDescription.name {
      return NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as! T
    }

    let error = CoreDataKitError.contextError(description: "Entity description '\(entityDescription)' has no name")
    throw error
  }

  /**
  Get description of an entity

  - parameter entity: Type of entity to describe

  - returns: Result with entity description of the given type
  */
  func entityDescription<T:NSManagedObject>(_ entity: T.Type) throws -> NSEntityDescription where T:NamedManagedObject
  {
    if let entityDescription = NSEntityDescription.entity(forEntityName: entity.entityName, in: self) {
      return entityDescription
    }

    throw CoreDataKitError.contextError(description: "Entity description for entity name '\(entity.entityName)' not found")
  }

  // MARK: - Deleting

  /**
  Delete object from this context

  - parameter managedObject: Object to delete

  - returns: Result wheter the delete was successful
  */
  public func deleteWithPermanentID(_ managedObject: NSManagedObject) throws {
    do {
      try self.obtainPermanentIDs(for: [managedObject])
    }
    catch {
      throw CoreDataKitError.coreDataError(error)
    }

    delete(managedObject)
  }

  // MARK: - Fetching

  /**
  Create a fetch request

  - parameter entity:          Type of entity to search for
  - parameter predicate:       Predicate to filter on
  - parameter sortDescriptors: Sort descriptors to sort on
  - parameter limit:           Maximum number of items to return
  - parameter offset:          The number of items to skip in the result

  - returns: Result with NSFetchRequest configured with the given parameters
  */
  public func createFetchRequest<T : NSManagedObject>(entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil, offset: Int? = nil) throws -> NSFetchRequest<T> where T:NamedManagedObject {
    let desc = try entityDescription(entity)
    return self.createFetchRequest(entityDescription: desc, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit, offset: offset)
  }

  @available(*, unavailable, renamed: "createFetchRequest(entity:)")
  public func createFetchRequest<T : NSManagedObject>(_ entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil, offset: Int? = nil) throws -> NSFetchRequest<T> where T:NamedManagedObject {
    fatalError()
  }

  /**
  Create a fetch request

  - parameter entity:          Type of entity to search for
  - parameter predicate:       Predicate to filter on
  - parameter sortDescriptors: Sort descriptors to sort on
  - parameter limit:           Maximum number of items to return
  - parameter offset:          The number of items to skip in the result

  - returns: NSFetchRequest configured with the given parameters
  */
  public func createFetchRequest<ResultType : NSFetchRequestResult>(entityDescription: NSEntityDescription, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil, offset: Int? = nil) -> NSFetchRequest<ResultType> {
    let fetchRequest = NSFetchRequest<ResultType>()
    fetchRequest.entity = entityDescription
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors
    fetchRequest.fetchLimit = limit ?? 0
    fetchRequest.fetchOffset = offset ?? 0
    fetchRequest.returnsObjectsAsFaults = true

    return fetchRequest
  }

  @available(*, unavailable, renamed: "createFetchRequest(entityDescription:)")
  public func createFetchRequest<ResultType : NSFetchRequestResult>(_ entityDescription: NSEntityDescription, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil, offset: Int? = nil) -> NSFetchRequest<ResultType> {
    fatalError()
  }

  /**
  Execute a fetch request

  - parameter fetchRequest: The request to execute on this context

  - returns: Result with array of entities found, empty array on no results
  */
  public func execute<T : NSManagedObject>(fetchRequest: NSFetchRequest<T>) throws -> [T] {
    do {
      return try fetch(fetchRequest)
    }
    catch {
      throw CoreDataKitError.coreDataError(error)
    }
  }

  @available(*, unavailable, renamed: "execute(fetchRequest:)")
  public func executeFetchRequest<T : NSManagedObject>(_ fetchRequest: NSFetchRequest<T>) throws -> [T] {
    fatalError()
  }

  // MARK: Fetched result controller

  /**
  Create a fetched results controller

  :discussion: Be aware that when you change to request but use the same cache as before stuff can mess up!

  - parameter fetchRequest:        Underlaying fetch request for the controller
  - parameter delegate:            Delegate, the controller will only observe changes when a delegate is present
  - parameter sectionNameKeyPath:  Keypath to section the results on
  - parameter cacheName:           Name of the cache to use, nil for no cache

  - returns: Fetched results controller that already has performed the fetch
  */
  public func fetchedResultsController<ResultType : NSFetchRequestResult>(fetchRequest: NSFetchRequest<ResultType>, delegate: NSFetchedResultsControllerDelegate? = nil, sectionNameKeyPath: String? = nil, cacheName: String? = nil) throws -> NSFetchedResultsController<ResultType> {
    let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
    resultsController.delegate = delegate

    var error: Error?

    performAndWait {
      do {
        try resultsController.performFetch()
      } catch let err {
        error = err
      }
    }

    if let error = error {
      throw CoreDataKitError.coreDataError(error)
    }

    return resultsController
  }

  @available(*, unavailable, renamed: "fetchedResultsController(fetchRequest:)")
  public func fetchedResultsController<ResultType : NSFetchRequestResult>(_ fetchRequest: NSFetchRequest<ResultType>, delegate: NSFetchedResultsControllerDelegate? = nil, sectionNameKeyPath: String? = nil, cacheName: String? = nil) throws -> NSFetchedResultsController<ResultType> {
    fatalError()
  }

  // MARK: Find helpers

  /**
  Looks the given managed object up in this context

  - parameter managedObject: Object from other context

  - returns: Result with the given object in this context
  */
  public func find<T:NSManagedObject>(_ entity: T.Type, managedObjectID: NSManagedObjectID) throws -> T {

    // First make sure we have a permanent ID for this object
//    if (managedObjectID.temporaryID) {
//        obtainPermanentIDsForObjects([managedObject], error: &optionalError)
//
//        if let error = optionalError {
//            return Result(error)
//        }
//    }

    do {
      let managedObjectInContext = try existingObject(with: managedObjectID)
      return managedObjectInContext as! T
    }
    catch {
      throw CoreDataKitError.coreDataError(error)
    }
  }

  /**
  Find entities of a certain type in this context

  - parameter entity:          Type of entity to search for
  - parameter predicate:       Predicate to filter on
  - parameter sortDescriptors: Sort descriptors to sort on
  - parameter limit:           Maximum number of items to return
  - parameter offset:          The number of items to skip in the result

  - returns: Result with array of entities found, empty array on no results
  */
  public func find<T:NSManagedObject>(_ entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil, offset: Int? = nil) throws -> [T] where T:NamedManagedObject {
    let desc = try entityDescription(entity)
    return try self.find(desc, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
  }

  /**
  Find entities of a certain type in this context based on its description

  - parameter entity:          Type of entity to search for
  - parameter predicate:       Predicate to filter on
  - parameter sortDescriptors: Sort descriptors to sort on
  - parameter limit:           Maximum number of items to return
  - parameter offset:          The number of items to skip in the result

  - returns: Result with array of entities found, empty array on no results
  */
  func find<T:NSManagedObject>(_ entityDescription: NSEntityDescription, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil, offset: Int? = nil) throws -> [T] {
    let fetchRequest: NSFetchRequest<T> = createFetchRequest(entityDescription: entityDescription, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    return try execute(fetchRequest: fetchRequest)
  }

  /**
  Get the first entity that matched the given parameters

  - parameter entity:          Type of entity to search for
  - parameter predicate:       Predicate to filter on
  - parameter sortDescriptors: Sort descriptors to sort on
  - parameter offset:          The number of items to skip in the result

  - returns: Result with the entity or result with nil if the entity is not found
  */
  public func findFirst<T:NSManagedObject>(_ entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int? = nil) throws -> T? where T:NamedManagedObject {
    let objects = try find(entity, predicate: predicate, sortDescriptors: sortDescriptors, limit: 1, offset: offset)
    return objects.first
  }
}
