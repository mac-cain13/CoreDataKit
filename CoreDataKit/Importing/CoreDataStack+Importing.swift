//
//  CoreDataStack+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 05-11-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension CoreDataStack {
    /**
    Dumps the current import configuration to the logger
    */
    public func dumpImportConfiguration() {
        let entityUserInfoKeys = [IdentifierUserInfoKey]

        for (entityName, _entity) in persistentStoreCoordinator.managedObjectModel.entitiesByName {
            CoreDataKit.sharedLogger(.DEBUG, " ")

            let entity = _entity as NSEntityDescription
            CoreDataKit.sharedLogger(.DEBUG, "\(entityName):")

            for (_key, value) in entity.userInfo! {
                let key = _key as String

                if !contains(entityUserInfoKeys, key) {
                    CoreDataKit.sharedLogger(.DEBUG, "  ⚠ \(key) → \(value)")
                }
            }

            let optionalIdentifyingAttribute = entity.identifyingAttribute().value()
            if let identifyingAttibute = optionalIdentifyingAttribute {
                dumpPropertyDescription(identifyingAttibute, asIdentifyingAttribute: true)
            }

            for (_, attribute) in entity.attributesByName {
                dumpPropertyDescription(attribute as NSPropertyDescription)
            }

            for (_, relationship) in entity.relationshipsByName {
                dumpPropertyDescription(relationship as NSPropertyDescription)
            }
        }
    }

    private func dumpPropertyDescription(property: NSPropertyDescription, asIdentifyingAttribute: Bool = false) {
        var propertyUserInfoKeys = [MappingUserInfoKey]
        for i in 0...MaxNumberedMappings+1 {
            propertyUserInfoKeys.append(MappingUserInfoKey + ".\(i)")
        }

        let attributeUserInfoKeys: [String] = []
        let relationshipUserInfoKeys = [RelationTypeUserInfoKey]

        let identifying = asIdentifyingAttribute ? "★" : " "
        let indexed = property.indexed ? "⚡" : ""
        let optional = property.optional ? "?" : ""
        let relationshipType = (property as? NSRelationshipDescription)?.relationType.rawValue
        let relationshipTypeDescription = relationshipType == nil ? "" : " → \(relationshipType!)"

        CoreDataKit.sharedLogger(.DEBUG, "\(identifying)\(indexed)\(property.name)\(optional) → \(property.mappings)\(relationshipTypeDescription)")

        for (_key, value) in property.userInfo! {
            let key = _key as String

            if !contains(propertyUserInfoKeys, key) {
                if (property is NSAttributeDescription && !contains(attributeUserInfoKeys, key)) ||
                    (property is NSRelationshipDescription && !contains(relationshipUserInfoKeys, key)) {
                    CoreDataKit.sharedLogger(.DEBUG, "  ⚠ \(key) → \(value)")
                }
            }
        }
    }
}
