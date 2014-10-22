//
//  NSManagedObject+Importing.swift
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
            performImport(transformedDictionary, error: error)
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

    public func willImport(dictionary: [String : AnyObject]) -> [String : AnyObject] {
        return dictionary
    }

    func performImport(dictionary: [String : AnyObject], error: NSErrorPointer) {
        for (name, _propertyDescription) in entity.propertiesByName {
            let propertyDescription = _propertyDescription as NSPropertyDescription
            let value: AnyObject? = propertyDescription.preferredValueFromDictionary(dictionary)

            switch (propertyDescription, value) {
            // Attribute
            case (is NSAttributeDescription, _):
                setValue(value, forKey: propertyDescription.name)

            // Nested relationship
            case let (relationshipDescription as NSRelationshipDescription, dictValue as [String: AnyObject]):
                if let destinationEntity = relationshipDescription.destinationEntity {
                    if let importedObject = managedObjectContext?.importEntity(destinationEntity, dictionary: dictValue, error: error) {
                        if (relationshipDescription.toMany) {
                            if let objectSet = valueForKey(relationshipDescription.name) as? NSMutableSet {
                                objectSet.addObject(importedObject)
                            } else if (nil != error) {
                                error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.RelationshipPropertyNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Can't append imported object to to-many relation '\(entity.name).\(relationshipDescription.name)' because it's not a NSMutableSet"])
                            }
                        } else {
                            setValue(importedObject, forKey: relationshipDescription.name)
                        }
                    }
                }

            // Multiple referenced / nested relationship
            case let (relationshipDescription as NSRelationshipDescription, dictValue as [AnyObject]):
                let noop = 0 // TODO

            // References relationship
            case let (relationshipDescription as NSRelationshipDescription, dictValue as String):
                let noop = 0 // TODO
            case let (relationshipDescription as NSRelationshipDescription, dictValue as NSNumber):
                let noop = 0 // TODO

            // Anything invalid
            default:
                let noop = 0 // TODO
            }
        }
    }

    public func didImport(dictionary: [String : AnyObject]) {
        // No-op
    }
}
