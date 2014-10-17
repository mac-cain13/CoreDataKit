//
//  Types.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 15-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

let CoreDataKitErrorDomain = "CoreDataKitErrorDomain"

enum CoreDataKitErrorCode: Int {
    case InvalidNumberOfResults = 1
    case EntityDescriptionNotFound
    case ImportCancelled
}

/**
Blocktype used to perform changes on a `NSManagedObjectContext`.

:param: context The context to perform your changes on
*/
public typealias PerformChangesBlock = (NSManagedObjectContext) -> Void

/**
Blocktype used to handle completion.

:param: error The error that occurred or nil if operation was successful
*/
public typealias CompletionHandler = (NSError?) -> Void
