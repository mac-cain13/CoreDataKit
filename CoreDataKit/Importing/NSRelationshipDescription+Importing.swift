//
//  NSRelationshipDescription+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 27-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSRelationshipDescription {

    /// Type of the relation as defined in the model
    var relationType: RelationType {
        let fallbackRelationType = RelationType.Reference

        if let relationTypeString = userInfo?[RelationTypeUserInfoKey] as? String {
            if let relationType = RelationType(rawValue: relationTypeString) {
                return relationType
            } else {
                CDK.sharedLogger(.ERROR, "Unsupported \(RelationTypeUserInfoKey) given for \(entity.name).\(name), falling back to \(fallbackRelationType.rawValue) relation type")
                return fallbackRelationType
            }
        }

        return fallbackRelationType
    }
}
