//
//  NSEntityDescription.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

let IdentifierUserInfoKey = "CDKId"

extension NSEntityDescription
{
    func identifyingAttribute(error: NSErrorPointer) -> NSAttributeDescription? {
        if let identifyingAttributeName = userInfo?[IdentifierUserInfoKey] as? String {
            if let identifyingAttribute = self.attributesByName[identifyingAttributeName] as? NSAttributeDescription {
                return identifyingAttribute
            } else if nil != error {
                error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.IdentifyingAttributeNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Found \(IdentifierUserInfoKey) with value '\(identifyingAttributeName)' but that isn't a valid attribute name"])
            }
        } else if let superEntity = self.superentity {
            return superEntity.identifyingAttribute(error)
        } else if nil != error {
            error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.IdentifyingAttributeNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "No \(IdentifierUserInfoKey) value found on \(name)"])
        }

        return nil
    }
}
