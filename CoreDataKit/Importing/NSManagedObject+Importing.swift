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
    /**
    Import dictionary into this managed object

    :param: dictionary The dictionary to import
    :param: error      If not succesful the error
    
    :returns: Wheter the import was performed (true if performed, false when cancelled by callback)
    */
    public func importDictionary(dictionary: [String : AnyObject]) -> Result<Void> {
        if shouldImport(dictionary) {
            let transformedDictionary = willImport(dictionary)
            let importResult = performImport(transformedDictionary)
            didImport(transformedDictionary, result: importResult)

            return importResult
        }

        let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.ImportCancelled.rawValue, userInfo: [NSLocalizedDescriptionKey: "Import of entity \(self.entity.name?) cancelled because shouldImport returned false"])
        return Result(error)
    }

    /**
    Will be called before import to determine wheter this dictionary should be imported into this object or not
    
    :discusion: Default implementation just returns true
    
    :param: dictionary The dictionary that will be imported

    :return: Wheter to import or not
    */
    public func shouldImport(dictionary: [String : AnyObject]) -> Bool {
        return true
    }

    /**
    Will be called right before import gives the chance to change the imported dictionary

    :discusion: Default implementation just returns the given dictionary

    :param: dictionary The dictionary that is given to the import method

    :return: The dictionary that will be used in the rest of the import process
    */
    public func willImport(dictionary: [String : AnyObject]) -> [String : AnyObject] {
        return dictionary
    }

    /// The real import logic
    private func performImport(dictionary: [String : AnyObject]) -> Result<Void> {
        if let context = managedObjectContext {
            for _propertyDescription in entity.properties {
                let propertyDescription = _propertyDescription as NSPropertyDescription

                switch propertyDescription {
                case let attributeDescription as NSAttributeDescription:
                    return performImportAttribute(attributeDescription, dictionary: dictionary)

                case let relationshipDescription as NSRelationshipDescription:
                    return performImportRelationship(relationshipDescription, dictionary: dictionary)

                case is NSFetchedPropertyDescription:
                    let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Importing NSFetchedPropertyDescription is not supported"])
                    return Result(error)

                default:
                    let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Importing unknown subclass or no subclass of NSPropertyDescription is not supported"])
                    return Result(error)
                }
            }
        }

        let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.ContextNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Managed object not inserted in context, objects must be inserted before importing"])
        return Result(error)
    }

    /// Helper to perform importing on attributes
    private func performImportAttribute(attribute: NSAttributeDescription, dictionary: [String : AnyObject]) -> Result<Void> {
        switch attribute.preferredValueFromDictionary(dictionary) {
        case let .Some(value):
            if let transformedValue: AnyObject = attribute.transformValue(value) {
                setValue(transformedValue, forKeyPath: attribute.name)
            } else {
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "Value '\(value)' could not be transformed to a value compatible with the type of \(entity.name).\(attribute.name)"])
                return Result(error)
            }

        case .Null:
            if (attribute.optional) {
                setValue(nil, forKeyPath: attribute.name)
            } else {
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "CoreData value is not optional, so null is not a valid option for attribute \(entity.name).\(attribute.name)"])
                return Result(error)
            }

        case .None:
            // Not found in dictionary, do not change value
            break;
        }

        return Result()
    }

    /// Helper to perform importing on relationships
    private func performImportRelationship(relationship: NSRelationshipDescription, dictionary: [String : AnyObject]) -> Result<Void> {
        if let destinationEntity = relationship.destinationEntity {
            switch relationship.preferredValueFromDictionary(dictionary) {
            case let .Some(value as [String: AnyObject]):
                switch managedObjectContext!.importEntity(destinationEntity, dictionary: value) {
                case let .Success(boxedObject):
                    return updateRelationshipWithValue(boxedObject.value, relationship: relationship)

                case let .Failure(boxedError):
                    return .Failure(boxedError)
                }

            case let .Some(value as [AnyObject]):
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnimplementedMethod.rawValue, userInfo: [NSLocalizedDescriptionKey: "Multiple referenced / nested relationships not yet supported"])
                return Result(error)

            case let .Some(value):
                switch managedObjectContext!.findEntityByIdentifyingAttribute(destinationEntity, identifyingValue: value) {
                case let .Success(boxedObject):
                    return updateRelationshipWithValue(boxedObject.value, relationship: relationship)

                case let .Failure(boxedError):
                    return .Failure(boxedError)
                }

            case .Null:
                if (relationship.optional) {
                    return updateRelationshipWithValue(nil, relationship: relationship)
                } else {
                    let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Relationship \(self.entity.name).\(relationship.name) is not optional, cannot set to null"])
                    return Result(error)
                }

            case .None:
                return Result() // Not found in dictionary, do not change value
            }
        } else {
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Relationship \(self.entity.name).\(relationship.name) has no destination entity defined"])
            return Result(error)
        }
    }

    /**
    Called after import is performed
    
    :param: dictionary The dictionary that is given to the import method
    */
    public func didImport(dictionary: [String : AnyObject], result: Result<Void>) {
        // No-op
    }

    /// Helper to update relationship value, adds or sets the relation to the given value or on nil value clears/deletes the whole relation
    private func updateRelationshipWithValue(_value: NSManagedObject?, relationship: NSRelationshipDescription) -> Result<Void> {
        if (relationship.toMany) {
            if let objectSet = valueForKeyPath(relationship.name) as? NSMutableSet {
                if let object = _value {
                    objectSet.addObject(object)
                } else {
                    objectSet.removeAllObjects()
                }
            } else {
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.RelationshipPropertyNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Can't append imported object to to-many relation '\(entity.name).\(relationship.name)' because it's not a NSMutableSet"])
                return Result(error)
            }
        } else {
            setValue(_value, forKeyPath: relationship.name)
        }

        return Result()
    }
}
