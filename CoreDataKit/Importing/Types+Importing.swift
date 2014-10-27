//
//  Types+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 27-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Key used on entity to define the identifying attribute in CoreData user info
let IdentifierUserInfoKey = "CDKId"

/// Key used on property to define mapping in CoreData user info
let MappingUserInfoKey = "CDKMap"

/// Maximum of numbered MappingUserInfoKeys on an property
let MaxNumberedMappings = 10

/// Value extracted from source that can be imported into a managed object
enum ImportableValue {
    // Some value is found
    case Some(AnyObject)

    // Value should be set to null
    case Null

    // No value is found
    case None
}
