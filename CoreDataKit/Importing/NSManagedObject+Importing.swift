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

    - parameter dictionary: The dictionary to import
    
    - returns: Result wheter the import was performed
    */
    public func importDictionary(dictionary: [String: AnyObject]) throws {
        if shouldImport(dictionary) {
            let transformedDictionary = willImport(dictionary)
            do {
                try performImport(transformedDictionary)
                didImport(transformedDictionary, error: nil)
            }
            catch let err {
                didImport(transformedDictionary, error: err)
                throw err
            }

            return
        }

        let entityName = self.entity.name ?? "nil"
        let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.ImportCancelled.rawValue, userInfo: [NSLocalizedDescriptionKey: "Import of entity \(entityName) cancelled because shouldImport returned false"])
        throw error
    }

// MARK: Steps in the import process

    /**
    Will be called before import to determine wheter this dictionary should be imported into this object or not
    
    :discusion: Default implementation just returns true
    
    - parameter dictionary: The dictionary that will be imported

    :return: Wheter to import or not
    */
    public func shouldImport(dictionary: [String: AnyObject]) -> Bool {
        return true
    }

    /**
    Will be called right before import gives the chance to change the imported dictionary

    :discusion: Default implementation just returns the given dictionary

    - parameter dictionary: The dictionary that is given to the import method

    :return: The dictionary that will be used in the rest of the import process
    */
    public func willImport(dictionary: [String: AnyObject]) -> [String: AnyObject] {
        return dictionary
    }

    /**
    Performs the import process

    - parameter dictionary: The dictionary to import
    
    - returns: Result wheter the import succeeded
    */
    private func performImport(dictionary: [String : AnyObject]) throws {
        if let context = managedObjectContext {
            for propertyDescription in entity.properties {

                switch propertyDescription {
                case let attributeDescription as NSAttributeDescription:
                    try performImportAttribute(attributeDescription, dictionary: dictionary)

                case let relationshipDescription as NSRelationshipDescription:
                    try performImportRelationship(context, relationship: relationshipDescription, dictionary: dictionary)

                case is NSFetchedPropertyDescription:
                    let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Importing NSFetchedPropertyDescription is not supported"])
                    throw error

                default:
                    let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Importing unknown subclass or no subclass of NSPropertyDescription is not supported"])
                    throw error
                }
            }
        } else {
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.ContextNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "Managed object not inserted in context, objects must be inserted before importing"])
            throw error
        }
    }

    /**
    Called after import is performed
    
    - parameter dictionary: The dictionary that was imported, this is the dictionary returned by willImport
    - parameter error: Optional error if import failed
    */
    public func didImport(dictionary: [String : AnyObject], error: ErrorType?) {
        // No-op
    }

// MARK: Import helpers

    /**
    Performs the import of one attribute

    - parameter attribute: The attribute to perform the import on
    - parameter dictionary: The dictionary to import from

    - returns: Result wheter import succeeded
    */
    private func performImportAttribute(attribute: NSAttributeDescription, dictionary: [String: AnyObject]) throws {
        switch attribute.preferredValueFromDictionary(dictionary) {
        case let .Some(value):
            if let transformedValue: AnyObject = attribute.transformValue(value) {
                setValue(transformedValue, forKeyPath: attribute.name)
            } else {
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "Value '\(value)' could not be transformed to a value compatible with the type of \(entity.name).\(attribute.name)"])
                throw error
            }

        case .Null:
            setValue(nil, forKeyPath: attribute.name) // We just set it to nil, maybe there is a default value in the model

        case .None:
            // Not found in dictionary, do not change value
            break;
        }
    }

    /**
    Performs the import of one attribute

    - parameter relationship: The relationship to perform the import on
    - parameter dictionary: The dictionary to import from

    - returns: Result wheter import succeeded
    */
    private func performImportRelationship(context: NSManagedObjectContext, relationship: NSRelationshipDescription, dictionary: [String : AnyObject]) throws {
        if let destinationEntity = relationship.destinationEntity {
            let importableValue = relationship.preferredValueFromDictionary(dictionary)

            switch relationship.relationType {
            case .Reference:
                try performImportReferenceRelationship(context, relationship: relationship, importableValue: importableValue, destinationEntity: destinationEntity)

            case .Embedding:
                try performImportEmbeddingRelationship(context, relationship: relationship, importableValue: importableValue, destinationEntity: destinationEntity)
            }
        } else {
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Relationship \(self.entity.name).\(relationship.name) has no destination entity defined"])
            error
        }
    }

    private func performImportReferenceRelationship(context: NSManagedObjectContext, relationship: NSRelationshipDescription, importableValue: ImportableValue, destinationEntity: NSEntityDescription) throws {
        switch importableValue {
        case let .Some(value as [String: AnyObject]):
            let object = try context.importEntity(destinationEntity, dictionary: value)
            try self.updateRelationship(context, relationship: relationship, withValue: object, deleteCurrent: false)

        case .Some(_ as [AnyObject]):
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnimplementedMethod.rawValue, userInfo: [NSLocalizedDescriptionKey: "Multiple referenced / nested relationships not yet supported with relation type \(RelationType.Reference)"])
            throw error

        case let .Some(value):
            let object = try context.findEntityByIdentifyingAttribute(destinationEntity, identifyingValue: value)
            try self.updateRelationship(context, relationship: relationship, withValue: object, deleteCurrent: false)

        case .Null:
            return try updateRelationship(context, relationship: relationship, withValue: nil, deleteCurrent: false)

        case .None:
            return // Not found in dictionary, do not change value
        }
    }

    private func performImportEmbeddingRelationship(context: NSManagedObjectContext, relationship: NSRelationshipDescription, importableValue: ImportableValue, destinationEntity: NSEntityDescription) throws {
        switch importableValue {
        case let .Some(value as [String: AnyObject]):
            let destinationObject = try context.create(destinationEntity)
            try destinationObject.importDictionary(value)
            try self.updateRelationship(context, relationship: relationship, withValue: destinationObject, deleteCurrent: true)


        case .Some(_ as [AnyObject]):
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnimplementedMethod.rawValue, userInfo: [NSLocalizedDescriptionKey: "Multiple nested relationships not yet supported with relation type \(RelationType.Embedding)"])
            throw error

        case .Some(_):
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnimplementedMethod.rawValue, userInfo: [NSLocalizedDescriptionKey: "Referenced relationships are not supported with relation type \(RelationType.Embedding)"])
            throw error

        case .Null:
            try self.updateRelationship(context, relationship: relationship, withValue: nil, deleteCurrent: true)
            
        case .None:
            return // Not found in dictionary, do not change value
        }
    }

    /**
    Helper to update relationship value, adds or sets the relation to the given value or on nil value clears/deletes the whole relation

    - parameter value: The value to update the relationship with
    - parameter relationship: The relationship to update

    :return: Wheter the update succeeded
    */
    private func updateRelationship(context: NSManagedObjectContext, relationship: NSRelationshipDescription, withValue _value: NSManagedObject?, deleteCurrent: Bool) throws {
        if (relationship.toMany) {
            if let objectSet = valueForKeyPath(relationship.name) as? NSMutableSet {
                if (deleteCurrent) {
                    for object in objectSet {
                        if let managedObject = object as? NSManagedObject {
                            do {
                                try context.delete(managedObject)
                            }
                            catch {
                            }
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
                throw error
            }
        } else {
            if (deleteCurrent) {
                if let currentRelatedObject = self.valueForKeyPath(relationship.name) as? NSManagedObject {
                    do {
                        try context.delete(currentRelatedObject)
                    }
                    catch {
                    }
                }
            }

            if let value = _value {
                setValue(value, forKeyPath: relationship.name)
            } else if (relationship.optional) {
                setValue(nil, forKeyPath: relationship.name)
            } else {
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidPropertyConfiguration.rawValue, userInfo: [NSLocalizedDescriptionKey: "Relationship \(self.entity.name).\(relationship.name) is not optional, cannot set to null"])
                throw error
            }
        }
    }
}
