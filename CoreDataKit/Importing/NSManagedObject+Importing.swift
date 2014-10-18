//
//  NSManagedObject.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 14-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSManagedObject
{
    public func importDictionary(dictionary: [String : AnyObject], error: NSErrorPointer) -> Bool {
        if shouldImport(dictionary) {
            let transformedDictionary = willImport(dictionary)
            performImport(transformedDictionary)
            didImport(transformedDictionary)

            return true
        } else {
            if nil != error {
                error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.ImportCancelled.rawValue, userInfo: [NSLocalizedDescriptionKey: "Import of entity \(self.entity.name?) cancelled because shouldImport returned false"])
            }
            return false
        }
    }

    public func shouldImport(dictionary: [String : AnyObject]) -> Bool {
        return true
    }

    func performImport(dictionary: [String : AnyObject]) {
        // TODO: Partially implemented method, relationships not really tested/implemented for example :)
        for (name, _propertyDescription) in entity.propertiesByName {
            let propertyDescription = _propertyDescription as NSPropertyDescription
            let value: AnyObject? = propertyDescription.preferredValueFromDictionary(dictionary)
            setValue(value, forKey: propertyDescription.name)
        }
    }

    public func willImport(dictionary: [String : AnyObject]) -> [String : AnyObject] {
        return dictionary
    }

    public func didImport(dictionary: [String : AnyObject]) {
        // No-op
    }
}
