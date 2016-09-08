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

    for (entityName, entity) in persistentStoreCoordinator.managedObjectModel.entitiesByName {
      CDK.sharedLogger(.debug, " ")
      CDK.sharedLogger(.debug, "\(entityName):")

      for (_key, value) in entity.userInfo! {
        let key = _key as! String

        if !entityUserInfoKeys.contains(key) {
          CDK.sharedLogger(.debug, "  ⚠ \(key) → \(value)")
        }
      }

      do {
        let identifyingAttibute = try entity.identifyingAttribute()
        dumpPropertyDescription(identifyingAttibute, asIdentifyingAttribute: true)
      }
      catch {
      }

      for (_, attribute) in entity.attributesByName {
        dumpPropertyDescription(attribute)
      }

      for (_, relationship) in entity.relationshipsByName {
        dumpPropertyDescription(relationship)
      }
    }
  }

  fileprivate func dumpPropertyDescription(_ property: NSPropertyDescription, asIdentifyingAttribute: Bool = false) {
    var propertyUserInfoKeys = [MappingUserInfoKey]
    for i in 0...MaxNumberedMappings+1 {
      propertyUserInfoKeys.append(MappingUserInfoKey + ".\(i)")
    }

    let attributeUserInfoKeys: [String] = []
    let relationshipUserInfoKeys = [RelationTypeUserInfoKey]

    let identifying = asIdentifyingAttribute ? "★" : " "
    let indexed = property.isIndexed ? "⚡" : ""
    let optional = property.isOptional ? "?" : ""
    let relationshipType = (property as? NSRelationshipDescription)?.relationType.rawValue
    let relationshipTypeDescription = relationshipType == nil ? "" : " → \(relationshipType!)"

    CDK.sharedLogger(.debug, "\(identifying)\(indexed)\(property.name)\(optional) → \(property.mappings)\(relationshipTypeDescription)")

    for (_key, value) in property.userInfo! {
      let key = _key as! String

      if !propertyUserInfoKeys.contains(key) {
        if (property is NSAttributeDescription && !attributeUserInfoKeys.contains(key)) ||
          (property is NSRelationshipDescription && !relationshipUserInfoKeys.contains(key)) {
            CDK.sharedLogger(.debug, "  ⚠ \(key) → \(value)")
        }
      }
    }
  }
}
