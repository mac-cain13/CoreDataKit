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

    :param: persistentStoreCoordinator Persistent store coordinator to associate with

    :returns: Managed object context
    */
    public convenience init(persistentStoreCoordinator: NSPersistentStoreCoordinator)
    {
        self.init(concurrencyType: .PrivateQueueConcurrencyType)
        performBlockAndWait { [unowned self] in
            self.persistentStoreCoordinator = persistentStoreCoordinator
        }
        beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
    }

    /**
    Create a new `NSManagedObjectContext` that has the given context set as parent context to save to.

    :discussion: The context will also obtain permanent IDs for `NSManagedObject`s before saving. This will prevent problems where you can't convert objects between two `NSManagedObjectContext`s, so it's advised to create context using this method.

    :param: concurrencyType Concurrency type to use, must be `NSPrivateQueueConcurrencyType` or `NSMainQueueConcurrencyType`
    :param: parentContext Parent context to associate with

    :returns: Managed object context
    */
    public convenience init(concurrencyType: NSManagedObjectContextConcurrencyType, parentContext: NSManagedObjectContext)
    {
        self.init(concurrencyType: concurrencyType)
        performBlockAndWait { [unowned self] in
            self.parentContext = parentContext
        }
        beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
    }

    /**
    Creates child context with this context as its parent

    :returns: Child context
    */
    public func createChildContext() -> NSManagedObjectContext {
        return NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType, parentContext: self)
    }

// MARK: - Saving

    /**
    Performs the given block on a child context and persists changes performed on the given context to the persistent store. After saving the `CompletionHandler` block is called and passed a `NSError` object when an error occured or nil when saving was successfull. The `CompletionHandler` will always be called on the thread the context performs it's operations on.

    :discussion: Do not nest save operations with this method, since the nested save will also save to the persistent store this will give unexpected results. Also the nested calls will not perform their changes on nested contexts, so the changes will not appear in the outer call as you'd expect to.

    :discussion: Please remember that `NSManagedObjects` are not threadsafe and your block is performed on another thread/`NSManagedObjectContext`. Make sure to **always** convert your `NSManagedObjects` to the given `NSManagedObjectContext` with `NSManagedObject.inContext()` or by looking up the `NSManagedObjectID` in the given context. This prevents disappearing data.

    :param: block       Block that performs the changes on the given context that should be saved
    :param: completion  Completion block to run after changes are saved
    */
    public func performBlock(block: PerformBlock, completionHandler: PerformBlockCompletionHandler? = nil) {
        performBlock {
            let commitAction = block(self)
            switch (commitAction) {
            case .DoNothing:
                completionHandler?(Result(commitAction))

            case .SaveToParentContext:
                var optionalError: NSError?
                self.save(&optionalError)

                let result = optionalError.map { Result($0) } ?? Result(commitAction)
                completionHandler?(result)

            case .SaveToPersistentStore:
                self.saveToPersistentStore {
                  let result = $0.map { commitAction }
                  completionHandler?(result)
                }
            }
        }
    }

    /**
    Save all changes in this context and all parent contexts to the persistent store, `CompletionHandler` will be called when finished.
    
    :discussion: Must be called from a perform block action
    
    :param: completionHandler  Completion block to run after changes are saved
    */
    func saveToPersistentStore(completionHandler: CompletionHandler? = nil)
    {
        var optionalError: NSError?
        save(&optionalError)

        switch (optionalError, self.parentContext) {
        case let (.None, .Some(parentContext)):
            parentContext.performBlock {
                parentContext.saveToPersistentStore(completionHandler)
            }

        default:
          completionHandler?(Result<Void>.withOptionalError(optionalError))
        }
    }

// MARK: Obtaining permanent IDs

    /// Installs a notification handler on the will save event that calls `obtainPermanentIDsForInsertedObjects()`
    func beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
    {
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextWillSaveNotification, object: self, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            self?.obtainPermanentIDsForInsertedObjects()
            return
        }
    }

    /**
    Obtains permanent object IDs for all objects inserted in this context. This ensures that the object has an object ID that you can lookup in an other context.

    @discussion This method is called automatically by `NSManagedObjectContext`s that are created by CoreDataKit right before saving. So usually you don't have to use this yourself if you stay within CoreDataKit created contexts.
    */
    public func obtainPermanentIDsForInsertedObjects() -> Result<Void>
    {
        if (self.insertedObjects.count > 0) {
            var optionalError: NSError?
            self.obtainPermanentIDsForObjects(self.insertedObjects.allObjects, error: &optionalError)

            if let error = optionalError {
                return Result(error)
            }
        }

        return Result()
    }

// MARK: - Creating

    /**
    Create and insert an entity into this context
    
    :param: entity Type of entity to create
    
    :returns: Result with the created entity
    */
    public func create<T:NSManagedObject where T:NamedManagedObject>(entity: T.Type) -> Result<T>
    {
        return entityDescription(entity).flatMap {
            self.create($0)
        }
    }

    /**
    Create and insert entity into this context based on its description

    :param: entityDescription Description of the entity to create

    :returns: Result with the created entity
    */
    func create<T:NSManagedObject>(entityDescription: NSEntityDescription) -> Result<T>
    {
        if let entityName = entityDescription.name {
            return Result(NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self) as T)
        }

        let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Entity description '\(entityDescription)' has no name"])
        return Result(error)
    }

    /**
    Get description of an entity

    :param: entity Type of entity to describe

    :returns: Result with entity description of the given type
    */
    func entityDescription<T:NSManagedObject where T:NamedManagedObject>(entity: T.Type) -> Result<NSEntityDescription>
    {
        if let entityDescription = NSEntityDescription.entityForName(entity.entityName, inManagedObjectContext: self) {
            return Result(entityDescription)
        }

        let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.EntityDescriptionNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Entity description for entity name '\(entity.entityName)' not found"])
        return Result(error)
    }

// MARK: - Deleting

    /**
    Delete object from this context
    
    :param: managedObject Object to delete

    :returns: Result wheter the delete was successful
    */
    public func delete(managedObject: NSManagedObject) -> Result<Void> {
        var optionalError: NSError?
        obtainPermanentIDsForObjects([managedObject], error: &optionalError)

        if let error = optionalError {
            return Result(error)
        }

        deleteObject(managedObject)
        return Result()
    }

// MARK: - Fetching

    /**
    Create a fetch request

    :param: entity          Type of entity to search for
    :param: predicate       Predicate to filter on
    :param: sortDescriptors Sort descriptors to sort on
    :param: limit           Maximum number of items to return
    :param: offset          The number of items to skip in the result

    :returns: Result with NSFetchRequest configured with the given parameters
    */
    public func createFetchRequest<T:NSManagedObject where T:NamedManagedObject>(entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil, offset: Int? = nil) -> Result<NSFetchRequest> {
        return entityDescription(entity).map {
            return self.createFetchRequest($0, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit, offset: offset)
        }
    }

    /**
    Create a fetch request

    :param: entity          Type of entity to search for
    :param: predicate       Predicate to filter on
    :param: sortDescriptors Sort descriptors to sort on
    :param: limit           Maximum number of items to return
    :param: offset          The number of items to skip in the result

    :returns: NSFetchRequest configured with the given parameters
    */
    public func createFetchRequest(entityDescription: NSEntityDescription, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil, offset: Int? = nil) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchLimit = limit ?? 0
        fetchRequest.fetchOffset = offset ?? 0
        fetchRequest.returnsObjectsAsFaults = true

        return fetchRequest
    }

    /**
    Execute a fetch request
    
    :param: fetchRequest The request to execute on this context
    
    :returns: Result with array of entities found, empty array on no results
    */
    public func executeFetchRequest<T:NSManagedObject>(fetchRequest: NSFetchRequest) -> Result<[T]> {
        var optionalError: NSError?
        let optionalResults = executeFetchRequest(fetchRequest, error: &optionalError)?.map { $0 as T }

        switch (optionalResults, optionalError) {
        case let (.Some(results), .None):
            return Result(results)

        case let (.None, .Some(error)):
            return Result(error)

        default:
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnknownError.rawValue, userInfo: [NSLocalizedDescriptionKey: "NSManagedObjectContext.executeFetchRequest returned invalid combination of return value (\(optionalResults)) and error (\(optionalError))"])
            return Result(error)
        }
    }

// MARK: Fetched result controller

    /**
    Create a fetched results controller
    
    :discussion: Be aware that when you change to request but use the same cache as before stuff can mess up!
    
    :param: fetchRequest        Underlaying fetch request for the controller
    :param: delegate            Delegate, the controller will only observe changes when a delegate is present
    :param: sectionNameKeyPath  Keypath to section the results on
    :param: cacheName           Name of the cache to use, nil for no cache
    
    :returns: Fetched results controller that already has performed the fetch
    */
    public func fetchedResultsController(fetchRequest: NSFetchRequest, delegate: NSFetchedResultsControllerDelegate? = nil, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> Result<NSFetchedResultsController> {
        let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        resultsController.delegate = delegate

        var optionalError: NSError?
        resultsController.performFetch(&optionalError)
        if let error = optionalError {
            return Result(error)
        }

        return Result(resultsController)
    }

// MARK: Find helpers

    /**
    Looks the given managed object up in this context
    
    :param: managedObject Object from other context

    :returns: Result with the given object in this context
    */
    public func find<T:NSManagedObject>(managedObject: T) -> Result<T> {
        var optionalError: NSError?

        // First make sure we have a permanent ID for this object
        if (managedObject.objectID.temporaryID) {
            obtainPermanentIDsForObjects([managedObject], error: &optionalError)

            if let error = optionalError {
                return Result(error)
            }
        }

        let optionalManagedObjectInContext = existingObjectWithID(managedObject.objectID, error: &optionalError)

        switch (optionalManagedObjectInContext, optionalError) {
        case let (.Some(managedObjectInContext), .None):
            return Result(managedObjectInContext as T)

        case let (.None, .Some(error)):
            return Result(error)

        default:
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnknownError.rawValue, userInfo: [NSLocalizedDescriptionKey: "NSManagedObjectContext.existingObjectWithID returned invalid combination of return value (\(optionalManagedObjectInContext)) and error (\(optionalError))"])
            return Result(error)
        }
    }

    /**
    Find entities of a certain type in this context
    
    :param: entity          Type of entity to search for
    :param: predicate       Predicate to filter on
    :param: sortDescriptors Sort descriptors to sort on
    :param: limit           Maximum number of items to return
    :param: offset          The number of items to skip in the result
    
    :returns: Result with array of entities found, empty array on no results
    */
    public func find<T:NSManagedObject where T:NamedManagedObject>(entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil, offset: Int? = nil) -> Result<[T]> {
        return entityDescription(entity).flatMap {
            self.find($0, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
        }
    }

    /**
    Find entities of a certain type in this context based on its description

    :param: entity          Type of entity to search for
    :param: predicate       Predicate to filter on
    :param: sortDescriptors Sort descriptors to sort on
    :param: limit           Maximum number of items to return
    :param: offset          The number of items to skip in the result

    :returns: Result with array of entities found, empty array on no results
    */
    func find<T:NSManagedObject>(entityDescription: NSEntityDescription, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil, offset: Int? = nil) -> Result<[T]> {
        let fetchRequest = createFetchRequest(entityDescription, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
        return executeFetchRequest(fetchRequest)
    }

    /**
    Get the first entity that matched the given parameters

    :param: entity          Type of entity to search for
    :param: predicate       Predicate to filter on
    :param: sortDescriptors Sort descriptors to sort on
    :param: offset          The number of items to skip in the result

    :returns: Result with the entity or result with nil if the entity is not found
    */
    public func findFirst<T:NSManagedObject where T:NamedManagedObject>(entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int? = nil) -> Result<T?> {
        return find(entity, predicate: predicate, sortDescriptors: sortDescriptors, limit: 1, offset: offset).map { $0.first }
    }
}
