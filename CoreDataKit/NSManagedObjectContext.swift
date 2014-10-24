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

    public func createChildContext() -> NSManagedObjectContext {
        return NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType, parentContext: self)
    }

// MARK: - Saving

    /**
    Performs the given block on a child context and persists changes performed on the given context to the persistent store. After saving the `CompletionHandler` block is called and passed a `NSError` object when an error occured or nil when saving was successfull. The `CompletionHandler` will always be called on the main thread.

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
                completionHandler?(commitAction, nil)

            case .SaveToParentContext:
                var optionalError: NSError?
                self.save(&optionalError)
                completionHandler?(commitAction, optionalError)

            case .SaveToPersistentStore:
                self.saveToPersistentStore {
                    completionHandler?(commitAction, $0)
                    return
                }
            }
        }
    }

    /**
    Save all changes in this context and all parent contexts to the persistent store, `CompletionHandler` will be called when finished.
    
    :discussion: Must be called from a perform block action
    
    :param: completionHandler  Completion block to run after changes are saved
    */
    public func saveToPersistentStore(completionHandler optionalCompletionHandler: CompletionHandler?)
    {
        var optionalError: NSError?
        save(&optionalError)

        switch (optionalError, self.parentContext, optionalCompletionHandler) {
        case let (.None, .Some(parentContext), _):
            parentContext.performBlock {
                parentContext.saveToPersistentStore(optionalCompletionHandler)
            }

        case let (_, _, .Some(completionHandler)):
            dispatch_async(dispatch_get_main_queue()) { completionHandler(optionalError) }

        default:
            break
        }
    }

// MARK: Obtaining permanent IDs

    /// Installs a notification handler on the will save event that calls `obtainPermanentIDsForInsertedObjects()`
    func beginObtainingPermanentIDsForInsertedObjectsWhenContextWillSave()
    {
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextWillSaveNotification, object: self, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            self?.obtainPermanentIDsForInsertedObjects(nil)
            return
        }
    }

    /**
    Obtains permanent object IDs for all objects inserted in this context. This ensures that the object has an object ID that you can lookup in an other context.

    @discussion This method is called automatically by `NSManagedObjectContext`s that are created by CoreDataKit right before saving. So usually you don't have to use this yourself if you stay within CoreDataKit created contexts.
    */
    public func obtainPermanentIDsForInsertedObjects(error: NSErrorPointer)
    {
        if (self.insertedObjects.count > 0) {
            self.obtainPermanentIDsForObjects(self.insertedObjects.allObjects, error: error)
        }
    }

// MARK: - Creating

    /**
    Create and insert an entity into this context
    
    :param: entity Type of entity to create
    :param: error  Error if not succesful
    
    :returns: Entity of the given type
    */
    public func create<T:NSManagedObject where T:NamedManagedObject>(entity: T.Type, error: NSErrorPointer) -> T?
    {
        if let entityDescription = entityDescription(entity, error: error) {
            return create(entityDescription)
        }

        return nil
    }

    /// Create and insert entity into this context based on its description
    func create<T:NSManagedObject>(entityDescription: NSEntityDescription) -> T?
    {
        if let entityName = entityDescription.name {
            return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self) as? T
        }

        return nil
    }

    /**
    Get description of an entity

    :param: entity Type of entity to describe
    :param: error  Error if not succesful

    :returns: Entity description of the given type
    */
    func entityDescription<T:NSManagedObject where T:NamedManagedObject>(entity: T.Type, error: NSErrorPointer) -> NSEntityDescription?
    {
        if let entityDescription = NSEntityDescription.entityForName(entity.entityName, inManagedObjectContext: self) {
            return entityDescription
        } else {
            if nil != error {
                error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.EntityDescriptionNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Entity description for entity name '\(entity.entityName)' not found"])
            }
            return nil
        }
    }

// MARK: - Deleting

    /**
    Delete object from this context
    
    :param: managedObject Object to delete
    :param: error         Error if not succesful
    */
    func delete(managedObject: NSManagedObject, error: NSErrorPointer) {
        obtainPermanentIDsForObjects([managedObject], error: error)
        deleteObject(managedObject)
    }

// MARK: - Finding

    /**
    Looks the given managed object up in this context
    
    :param: managedObject Object from other context
    :error: error           Error if not succesful

    :returns: The object in this context or nil if not found
    */
    public func convert<T:NSManagedObject>(managedObject: T, error: NSErrorPointer) -> T? {
        // First make sure we have a permanent ID for this object
        if (managedObject.objectID.temporaryID) {
            obtainPermanentIDsForObjects([managedObject], error: error)
        }

        if let managedObjectInContext = existingObjectWithID(managedObject.objectID, error: error) {
            return managedObjectInContext as? T
        }

        return nil
    }

    /**
    Find all entities of a certain type
    
    :param: entity          Type of entity to search for
    :error: error           Error if not succesful

    :returns: Array of entities found, empty array on no results, nil on error
    */
    public func all<T:NSManagedObject where T:NamedManagedObject>(entity: T.Type, error: NSErrorPointer) -> [T]? {
        return find(entity, predicate: nil, sortDescriptors: nil, limit: nil, error: error)
    }

    /**
    Find entities of a certain type in this context
    
    :param: entity          Type of entity to search for
    :param: predicate       Predicate to filter on
    :param: sortDescriptors Sort descriptors to sort on
    :param: limit           Maximum number of items to return
    :error: error           Error if not succesful
    
    :returns: Array of entities found, empty array on no results, nil on error
    */
    public func find<T:NSManagedObject where T:NamedManagedObject>(entity: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int?, error: NSErrorPointer) -> [T]? {
        if let entityDescription = entityDescription(entity, error: error) {
            return find(entityDescription, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit, error: error)
        }

        return nil
    }

    /// Find entities of a certain type in this context based on its description
    func find<T:NSManagedObject>(entityDescription: NSEntityDescription, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int?, error: NSErrorPointer) -> [T]? {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchLimit = limit ?? 0
        fetchRequest.returnsObjectsAsFaults = true

        return executeFetchRequest(fetchRequest, error: error)?.map { $0 as T }
    }
}
