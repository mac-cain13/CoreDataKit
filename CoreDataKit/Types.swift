//
//  Types.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 15-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

/// Commit actions that can be taken by CoreDataKit after a block of changes is performed
public enum CommitAction {
    /// Do not do any save/rollback operation, just leave the changes on the context unsaved
    case DoNothing

    /// Save all changes in this context to the parent context
    case SaveToParentContext

    /// Save all changes in this and all parent contexts to the persistent store
    case SaveToPersistentStore

    /// Undo changes done in the related PerformBlock, all other changes will remain untouched
    case Undo

    /// Rollback all changes on the context, this will revert all unsaved changes in the context
    case RollbackAllChanges
}

/**
Blocktype used to perform changes on a `NSManagedObjectContext`.

- parameter context: The context to perform your changes on
*/
public typealias PerformBlock = NSManagedObjectContext -> CommitAction

/**
Blocktype used to handle completion.

- parameter result: Wheter the operation was successful
*/
public typealias CompletionHandler = (arg: () throws -> Void) -> Void

/**
Blocktype used to handle completion of `PerformBlock`s.

- parameter result:       Wheter the operation was successful
- parameter commitAction: The type of commit action the block has done
*/
public typealias PerformBlockCompletionHandler = (arg: () throws -> CommitAction) -> Void

// MARK: - Errors

/// Error domain used by CoreDataKit when it generates a NSError
public let CoreDataKitErrorDomain = "CoreDataKitErrorDomain"

/// Error codes used by CoreDataKit when it generates a NSError
public enum CoreDataKitErrorCode: Int {
    case UnknownError = 1

    /// The method is unimplemented or should be overridden without calling super
    case UnimplementedMethod

    case ContextNotFound

    /// Entity description could not be found
    case EntityDescriptionNotFound

    /// Idenifying attribute could not be found
    case IdentifyingAttributeNotFound

    /// Relationship property could not be found
    case RelationshipPropertyNotFound

    /// Invalid configuration of property for the action you want to perform
    case InvalidPropertyConfiguration

    case InvalidValue

    /// Number of results was not within the expected range
    case UnexpectedNumberOfResults

    /// Import was cancelled
    case ImportCancelled
}
