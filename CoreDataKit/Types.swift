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

  init(value: T) {
    self.value = value
  }
}

/// The result type used for nearly all failable operations
public enum Result<T> {
    /// Indicated success of the operation and contains a boxed result value
    case Success(Box<T>)

    /// Indicates failure of the operation and contains a boxes error value
    case Failure(NSError)

    /// Initialize with a success value, boxes it for you
    internal init(_ value: T) {
        self = .Success(Box(value: value))
    }

    /// Initialize with a error value, boxes it for you
    internal init(_ value: NSError) {
        self = .Failure(value)
    }

    /**
    Create Result from optional error, failure with error if optional contains a value. Void success Result otherwise.
    
    :param: optionalError The error to create result from
    
    :returns: Result containing the error or Success when no error present
    */
    static func withOptionalError(optionalError: NSError?) -> Result<Void> {
        if let error = optionalError {
            return Result<Void>(error)
        }

        return Result<Void>()
    }

    /**
    Get the unboxed success value
    
    :returns: The unboxed success value or nil on failure
    */
    public func value() -> T? {
        switch self {
        case let .Success(boxedValue):
            return boxedValue.value

        default:
            return nil
        }
    }

    /**
    Get the error

    :returns: The unboxed failure value or nil on success
    */
    public func error() -> NSError? {
        switch self {
        case let .Failure(error):
            return error

        default:
            return nil
        }
    }

    public func map<U>(f: T -> U) -> Result<U> {
        switch self {
        case let .Success(x):
            return .Success(Box(value: f(x.value)))

        case let .Failure(x):
            return .Failure(x)
        }
    }

    public static func flatten<T>(result: Result<Result<T>>) -> Result<T> {
        switch result {
        case let .Success(x):
            return x.value

        case let .Failure(x):
            return .Failure(x)
        }
    }

    public func flatMap<U>(f: T -> Result<U>) -> Result<U> {
        return Result.flatten(map(f))
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
public typealias PerformBlock = NSManagedObjectContext -> CommitAction

/**
Blocktype used to handle completion.

:param: result Wheter the operation was successful
*/
public typealias CompletionHandler = Result<Void> -> Void

/**
Blocktype used to handle completion of `PerformBlock`s.

:param: result       Wheter the operation was successful
:param: commitAction The type of commit action the block has done
*/
public typealias PerformBlockCompletionHandler = Result<CommitAction> -> Void

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
