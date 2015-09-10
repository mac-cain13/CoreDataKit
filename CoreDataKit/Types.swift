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

/// All errors that can occure from CoreDataKit

public enum CoreDataKitError : ErrorType {
  case CoreDataError(ErrorType)

  case ImportCancelled(entityName: String)
  case ImportError(description: String)
  case ContextError(description: String)
  case UnimplementedMethod(description: String)

  case UnknownError(description: String)
}

extension CoreDataKitError : CustomStringConvertible {
  public var description: String {
    switch self {
    case .CoreDataError(let error):
      return "CoreDataError: \(error)"
    case .ImportCancelled(let entityName):
      return "Import of entity \(entityName) cancelled"
    case .ContextError(let description):
      return description
    case .ImportError(let description):
      return description
    case .UnimplementedMethod(let description):
      return description
    case .UnknownError(let description):
      return "Unknown error: \(description)"
    }
  }
}

/// Wrapping CoreDataKitError in a NSError for compatibility with older NSError-based code

public let CoreDataKitErrorDomain = "CoreDataKitErrorDomain"

private let CoreDataKitErrorUserInfoErrorKey = "CoreDataKitErrorUserInfoErrorKey"

public class CoreDataKitErrorBox : CustomStringConvertible {
  public let unbox: CoreDataKitError

  init(value: CoreDataKitError) {
    self.unbox = value
  }

  public var description: String {
    return unbox.description
  }
}

extension CoreDataKitError {

  public var nsError: NSError {
    switch self {
    case .CoreDataError(let error):
      return error as NSError
    default:
      return NSError(
        domain: CoreDataKitErrorDomain,
        code: 0,
        userInfo: [CoreDataKitErrorUserInfoErrorKey: CoreDataKitErrorBox(value: self)])
    }
  }
}

extension NSError {
  public var coreDataKitError: CoreDataKitError? {
    if let boxed = self.userInfo[CoreDataKitErrorUserInfoErrorKey] as? CoreDataKitErrorBox {
      return boxed.unbox
    }
    return nil
  }
}
