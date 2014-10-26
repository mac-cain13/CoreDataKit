//
//  Types.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 15-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

public class Box<T> {
    public let value: T

    init(_ _value: T) {
        value = _value
    }
}

public enum Result<T> {
    case Success(Box<T>)
    case Failure(Box<NSError>)

    init(_ value: T) {
        self = .Success(Box(value))
    }

    init(_ value: NSError) {
        self = .Failure(Box(value))
    }

    public func successValue() -> T? {
        switch self {
        case let .Success(box):
            return box.value

        default:
            return nil
        }
    }

    public func failureValue() -> NSError? {
        switch self {
        case let .Failure(box):
            return box.value

        default:
            return nil
        }
    }
}

/// Commit actions that can be taken by CoreDataKit after a block of changes is performed
public enum CommitAction {
    /// Do not do any save/rollback operation, just leave the changes on the context unsaved
    case DoNothing

    /// Save all changes in this context to the parent context
    case SaveToParentContext

    /// Save all changes in this and all parent contexts to the persistent store
    case SaveToPersistentStore

    /// Undo changes done in the related PerformBlock, all other changes will remain untouched
//    case Undo

    /// Rollback all changes on the context, this will revert all unsaved changes in the context
//    case RollbackAllChanges
}

/**
Blocktype used to perform changes on a `NSManagedObjectContext`.

:param: context The context to perform your changes on
*/
public typealias PerformBlock = (NSManagedObjectContext) -> CommitAction

/**
Blocktype used to handle completion.

:param: error The error that occurred or nil if operation was successful
*/
public typealias CompletionHandler = (NSError?) -> Void

/**
Blocktype used to handle completion of `PerformBlock`s.

:param: commitAction The type of commit action the block has done
:param: error        The error that occurred or nil if operation was successful
*/
public typealias PerformBlockCompletionHandler = (CommitAction, NSError?) -> Void

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
