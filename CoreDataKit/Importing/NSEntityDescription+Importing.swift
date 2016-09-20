//
//  NSEntityDescription+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSEntityDescription
{
  /**
  Get the attribute description of this entity description that is marked as identifier in the model

  - returns: Result with the identifying attribute description
  */
  func identifyingAttribute() throws -> NSAttributeDescription {
    if let identifyingAttributeName = userInfo?[IdentifierUserInfoKey] as? String {
      if let identifyingAttribute = self.attributesByName[identifyingAttributeName] {
        return identifyingAttribute
      }

      let error = CoreDataKitError.importError(description: "Found \(IdentifierUserInfoKey) with value '\(identifyingAttributeName)' but that isn't a valid attribute name")
      throw error
    } else if let superEntity = self.superentity {
      return try superEntity.identifyingAttribute()
    }

    let error = CoreDataKitError.importError(description: "No \(IdentifierUserInfoKey) value found on \(name)")
    throw error
  }
}
