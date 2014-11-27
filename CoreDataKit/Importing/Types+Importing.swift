//
//  Types+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 27-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import Foundation

// MARK: - User info values

/// Key used on entity to define the identifying attribute in CoreData user info
let IdentifierUserInfoKey = "CDKId"

// MARK: Mapping

/// Key used on property to define mapping in CoreData user info
let MappingUserInfoKey = "CDKMap"

/// Value used with MappingUserInfoKey to disable all mapping behaviour
let SuppressMappingUserInfoValue = "CDKNoMapping"

/// Maximum of numbered MappingUserInfoKeys on an property
let MaxNumberedMappings = 10

// MARK: Relations

/// Key used on relation to define type of the relation in CoreData user info
let RelationTypeUserInfoKey = "CDKRelationType"

/// Values used with RelationTypeUserInfoKey to alter relation type
enum RelationType: String {
    /// Relation that is referenced by a primary key like ID
    case RelatedById = "CDKRelatedById"

    /// Relation that doesn't use a ID of some sort
    case Embedding = "CDKEmbedding"

    static func fromString(string: String) -> RelationType {
        return RelationType(rawValue: string) ?? .RelatedById
    }
}

// MARK: - Importable value

/// Value extracted from source that can be imported into a managed object
enum ImportableValue {
    // Some value is found
    case Some(AnyObject)

    // Value should be set to null
    case Null

    // No value is found
    case None
}
