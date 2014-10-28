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
    
    :returns: Result with the identifying attribute description
    */
    func identifyingAttribute() -> Result<NSAttributeDescription> {
        if let identifyingAttributeName = userInfo?[IdentifierUserInfoKey] as? String {
            if let identifyingAttribute = self.attributesByName[identifyingAttributeName] as? NSAttributeDescription {
                return Result(identifyingAttribute)
            }

            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.IdentifyingAttributeNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Found \(IdentifierUserInfoKey) with value '\(identifyingAttributeName)' but that isn't a valid attribute name"])
            return Result(error)
        } else if let superEntity = self.superentity {
            return superEntity.identifyingAttribute()
        }

        let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.IdentifyingAttributeNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "No \(IdentifierUserInfoKey) value found on \(name)"])
        return Result(error)
    }
}
