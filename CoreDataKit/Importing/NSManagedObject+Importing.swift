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
    private func performImport(dictionary: [String : AnyObject], error: NSErrorPointer) {
        if let context = managedObjectContext {
            for _propertyDescription in entity.properties {
                let propertyDescription = _propertyDescription as NSPropertyDescription

                switch propertyDescription {
                case let attributeDescription as NSAttributeDescription:
                    performImportAttribute(attributeDescription, dictionary: dictionary, error: error)

                case let relationshipDescription as NSRelationshipDescription:
                    performImportRelationship(relationshipDescription, dictionary: dictionary, error: error)

                case is NSFetchedPropertyDescription:
                    if (nil != error) {
                        error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Importing NSFetchedPropertyDescription is not supported"])
                    }

                default:
                    if (nil != error) {
                        error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Importing unknown subclass or no subclass of NSPropertyDescription is not supported"])
                    }
                }
            }
        } else if (nil != error) {
            error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.ContextNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Managed object not inserted in context, objects must be inserted before importing"])
        }
    }

    /// Helper to perform importing on attributes
    private func performImportAttribute(attribute: NSAttributeDescription, dictionary: [String : AnyObject], error: NSErrorPointer) {
        switch attribute.preferredValueFromDictionary(dictionary) {
        case let .Some(value):
            if let transformedValue: AnyObject = attribute.transformValue(value) {
                setValue(transformedValue, forKeyPath: attribute.name)
            } else if (nil != error) {
                error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "Value '\(value)' could not be transformed to a value compatible with the type of \(entity.name).\(attribute.name)"])
            }

        case .Null:
            if (attribute.optional) {
                setValue(nil, forKeyPath: attribute.name)
            } else if (nil != error) {
                error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "CoreData value is not optional, so null is not a valid option for attribute \(entity.name).\(attribute.name)"])
            }

        case .None:
            // Not found in dictionary, do not change value
            break;
        }
    }

    /// Helper to perform importing on relationships
    private func performImportRelationship(relationship: NSRelationshipDescription, dictionary: [String : AnyObject], error: NSErrorPointer) {
        if let destinationEntity = relationship.destinationEntity {
            switch relationship.preferredValueFromDictionary(dictionary) {
            case let .Some(value as [String: AnyObject]):
                if let importedObject = managedObjectContext?.importEntity(destinationEntity, dictionary: value, error: error) {
                    updateRelationshipWithValue(importedObject, relationship: relationship, error: error)
                }

            case let .Some(value as [AnyObject]):
                if (nil != error) {
                    error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnimplementedMethod.rawValue, userInfo: [NSLocalizedDescriptionKey: "Multiple referenced / nested relationships not yet supported"])
                }
                break

            case let .Some(value):
                if let relatedObject = managedObjectContext?.findEntityByIdentifyingAttribute(destinationEntity, identifyingValue: value, error: error) {
                    updateRelationshipWithValue(relatedObject, relationship: relationship, error: error)
                }

            case .Null:
                if (relationship.optional) {
                    updateRelationshipWithValue(nil, relationship: relationship, error: error)
                } else if (nil != error) {
                    error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Relationship \(self.entity.name).\(relationship.name) is not optional, cannot set to null"])
                }

            case .None:
                // Not found in dictionary, do not change value
                break;
            }
        } else if (nil != error) {
            error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Relationship \(self.entity.name).\(relationship.name) has no destination entity defined"])
        }
    }

    /**
    Called after import is performed
    
    :param: dictionary The dictionary that is given to the import method
    */
    public func didImport(dictionary: [String : AnyObject]) {
        // No-op
    }

    /// Helper to update relationship value, adds or sets the relation to the given value or on nil value clears/deletes the whole relation
    private func updateRelationshipWithValue(_value: NSManagedObject?, relationship: NSRelationshipDescription, error: NSErrorPointer) {
        if (relationship.toMany) {
            if let objectSet = valueForKeyPath(relationship.name) as? NSMutableSet {
                if let object = _value {
                    objectSet.addObject(object)
                } else {
                    objectSet.removeAllObjects()
                }
            } else if (nil != error) {
                error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.RelationshipPropertyNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Can't append imported object to to-many relation '\(entity.name).\(relationship.name)' because it's not a NSMutableSet"])
            }
        } else {
            setValue(_value, forKeyPath: relationship.name)
        }
    }
}
