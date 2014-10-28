//
//  NSRelationshipDescription+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 27-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSRelationshipDescription {
    var relationType: RelationType {
        if let relationTypeString = userInfo?[RelationTypeUserInfoKey] as? String {
            return RelationType.fromString(relationTypeString)
        }

        return RelationType.RelatedById
    }
}
