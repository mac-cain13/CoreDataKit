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
    Import a dictionary into this managed object

    :param: dictionary The dictionary to import
    
    :returns: Result wheter the import was performed
    */
    public func importDictionary(dictionary: [String: AnyObject]) -> Result<Void> {
        if shouldImport(dictionary) {
            let transformedDictionary = willImport(dictionary)
            let importResult = performImport(transformedDictionary)
            didImport(transformedDictionary, result: importResult)

            return importResult
        }

        let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.ImportCancelled.rawValue, userInfo: [NSLocalizedDescriptionKey: "Import of entity \(self.entity.name?) cancelled because shouldImport returned false"])
        return Result(error)
    }

// MARK: Steps in the import process

    /**
    Will be called before import to determine wheter this dictionary should be imported into this object or not
    
    :discusion: Default implementation just returns true
    
    :param: dictionary The dictionary that will be imported

    :return: Wheter to import or not
    */
    public func shouldImport(dictionary: [String: AnyObject]) -> Bool {
        return true
    }

    /**
    Will be called right before import gives the chance to change the imported dictionary

    :discusion: Default implementation just returns the given dictionary

    :param: dictionary The dictionary that is given to the import method

    :return: The dictionary that will be used in the rest of the import process
    */
    public func willImport(dictionary: [String: AnyObject]) -> [String: AnyObject] {
        return dictionary
    }

    /**
    Performs the import process

    :param: dictionary The dictionary to import
    
    :returns: Result wheter the import succeeded
    */
    private func performImport(dictionary: [String : AnyObject]) -> Result<Void> {
        if let context = managedObjectContext {
            for _propertyDescription in entity.properties {
                let propertyDescription = _propertyDescription as NSPropertyDescription

                switch propertyDescription {
                case let attributeDescription as NSAttributeDescription:
                    if let error = performImportAttribute(attributeDescription, dictionary: dictionary).error() {
                        return Result(error) // Abort import
                    }

                case let relationshipDescription as NSRelationshipDescription:
                    if let error = performImportRelationship(relationshipDescription, dictionary: dictionary).error()  {
                        return Result(error) // Abort import
                    }

                case is NSFetchedPropertyDescription:
                    let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Importing NSFetchedPropertyDescription is not supported"])
                    return Result(error)

                default:
                    let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Importing unknown subclass or no subclass of NSPropertyDescription is not supported"])
                    return Result(error)
                }
            }

            return Result()
        } else {
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.ContextNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Managed object not inserted in context, objects must be inserted before importing"])
            return Result(error)
        }
    }

    /**
    Called after import is performed
    
    :param: dictionary The dictionary that was imported, this is the dictionary returned by willImport
    :param: result Whether the import succeeded
    */
    public func didImport(dictionary: [String : AnyObject], result: Result<Void>) {
        // No-op
    }

// MARK: Import helpers

    /**
    Performs the import of one attribute

    :param: attribute The attribute to perform the import on
    :param: dictionary The dictionary to import from

    :returns: Result wheter import succeeded
    */
    private func performImportAttribute(attribute: NSAttributeDescription, dictionary: [String: AnyObject]) -> Result<Void> {
        switch attribute.preferredValueFromDictionary(dictionary) {
        case let .Some(value):
            if let transformedValue: AnyObject = attribute.transformValue(value) {
                setValue(transformedValue, forKeyPath: attribute.name)
            } else {
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "Value '\(value)' could not be transformed to a value compatible with the type of \(entity.name).\(attribute.name)"])
                return Result(error)
            }

        case .Null:
            setValue(nil, forKeyPath: attribute.name) // We just set it to nil, maybe there is a default value in the model

        case .None:
            // Not found in dictionary, do not change value
            break;
        }

        return Result()
    }

    /**
    Performs the import of one attribute

    :param: relationship The relationship to perform the import on
    :param: dictionary The dictionary to import from

    :returns: Result wheter import succeeded
    */
    private func performImportRelationship(relationship: NSRelationshipDescription, dictionary: [String : AnyObject]) -> Result<Void> {
        if let destinationEntity = relationship.destinationEntity {
            let importableValue = relationship.preferredValueFromDictionary(dictionary)

            switch relationship.relationType {
            case .Reference:
                return performImportReferenceRelationship(relationship, importableValue: importableValue, destinationEntity: destinationEntity)

            case .Embedding:
                return performImportEmbeddingRelationship(relationship, importableValue: importableValue, destinationEntity: destinationEntity)
            }
        } else {
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Relationship \(self.entity.name).\(relationship.name) has no destination entity defined"])
            return Result(error)
        }
    }

    private func performImportReferenceRelationship(relationship: NSRelationshipDescription, importableValue: ImportableValue, destinationEntity: NSEntityDescription)  -> Result<Void> {
        switch importableValue {
        case let .Some(value as [String: AnyObject]):
            return managedObjectContext!.importEntity(destinationEntity, dictionary: value).flatMap {
                self.updateRelationship(relationship, withValue: $0, deleteCurrent: false)
            }

        case let .Some(value as [AnyObject]):
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnimplementedMethod.rawValue, userInfo: [NSLocalizedDescriptionKey: "Multiple referenced / nested relationships not yet supported with relation type \(RelationType.Reference)"])
            return Result(error)

        case let .Some(value):
            return managedObjectContext!.findEntityByIdentifyingAttribute(destinationEntity, identifyingValue: value).flatMap {
                self.updateRelationship(relationship, withValue: $0, deleteCurrent: false)
            }

        case .Null:
            return updateRelationship(relationship, withValue: nil, deleteCurrent: false)

        case .None:
            return Result() // Not found in dictionary, do not change value
        }
    }

    private func performImportEmbeddingRelationship(relationship: NSRelationshipDescription, importableValue: ImportableValue, destinationEntity: NSEntityDescription)  -> Result<Void> {
        switch importableValue {
        case let .Some(value as [String: AnyObject]):
            return managedObjectContext!.create(destinationEntity).flatMap { destinationObject in
                return destinationObject.importDictionary(value).flatMap {
                    return self.updateRelationship(relationship, withValue: destinationObject, deleteCurrent: true)
                }
            }

        case let .Some(value as [AnyObject]):
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnimplementedMethod.rawValue, userInfo: [NSLocalizedDescriptionKey: "Multiple nested relationships not yet supported with relation type \(RelationType.Embedding)"])
            return Result(error)

        case let .Some(value):
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnimplementedMethod.rawValue, userInfo: [NSLocalizedDescriptionKey: "Referenced relationships are not supported with relation type \(RelationType.Embedding)"])
            return Result(error)

        case .Null:
            return self.updateRelationship(relationship, withValue: nil, deleteCurrent: true)
            
        case .None:
            return Result() // Not found in dictionary, do not change value
        }
    }

    /**
    Helper to update relationship value, adds or sets the relation to the given value or on nil value clears/deletes the whole relation

    :param: value The value to update the relationship with
    :param: relationship The relationship to update

    :return: Wheter the update succeeded
    */
    private func updateRelationship(relationship: NSRelationshipDescription, withValue _value: NSManagedObject?, deleteCurrent: Bool) -> Result<Void> {
        if (relationship.toMany) {
            if let objectSet = valueForKeyPath(relationship.name) as? NSMutableSet {
                if (deleteCurrent) {
                    for object in objectSet {
                        if let managedObject = object as? NSManagedObject {
                            managedObjectContext!.delete(managedObject)
                        }
                    }
                }

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
            if (deleteCurrent) {
                if let currentRelatedObject = self.valueForKeyPath(relationship.name) as? NSManagedObject {
                    managedObjectContext!.delete(currentRelatedObject)
                }
            }

            if let value = _value {
                setValue(value, forKeyPath: relationship.name)
            } else if (relationship.optional) {
                setValue(nil, forKeyPath: relationship.name)
            } else {
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Relationship \(self.entity.name).\(relationship.name) is not optional, cannot set to null"])
                return Result(error)
            }
        }
        
        return Result()
    }
}
