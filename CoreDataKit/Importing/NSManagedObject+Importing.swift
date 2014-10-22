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
                        addObjectToRelationship(importedObject, relationship: relationshipDescription, error: error)
                    }
                }

            // Multiple referenced / nested relationship
            case let (relationshipDescription as NSRelationshipDescription, dictValue as [AnyObject]):
                let noop = 0 // TODO

            // Referenced relationship
            case let (relationshipDescription as NSRelationshipDescription, .Some(value)):
                if let destinationEntity = relationshipDescription.destinationEntity {
                    if let relatedObject = managedObjectContext?.findEntityByIdentifyingAttribute(destinationEntity, identifyingValue: value, error: error) {
                        addObjectToRelationship(relatedObject, relationship: relationshipDescription, error: error)
                    }
                }

            // Anything invalid
            default:
                break
            }
        }
    }

    public func didImport(dictionary: [String : AnyObject]) {
        // No-op
    }

    private func addObjectToRelationship(object: NSManagedObject, relationship: NSRelationshipDescription, error: NSErrorPointer) {
        if (relationship.toMany) {
            if let objectSet = valueForKey(relationship.name) as? NSMutableSet {
                objectSet.addObject(object)
            } else if (nil != error) {
                error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.RelationshipPropertyNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Can't append imported object to to-many relation '\(entity.name).\(relationship.name)' because it's not a NSMutableSet"])
            }
        } else {
            setValue(object, forKey: relationship.name)
        }
    }
}
