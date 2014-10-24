//
//  NSManagedObjectContext+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSManagedObjectContext
{
    /**
    Import dictionary into the given type of entity, will do lookups in the context to find the object to import
    
    :param: entity      Type of entity to import
    :param: dictionary  Data to import
    :param: error       Error if not succesful
    
    :returns: Managed object of the given entity type with the data imported on it or nil on failure
    
    :see: Importing documentation at [TODO]
    */
    public func importEntity<T: NSManagedObject where T:NamedManagedObject>(entity: T.Type, dictionary: [String : AnyObject], error: NSErrorPointer) -> T? {
        if let entityDescription = entityDescription(entity, error: error) {
            return importEntity(entityDescription, dictionary: dictionary, error: error)
        }

        return nil
    }

    /// Import dictionary into an entity based on entity description
    func importEntity<T:NSManagedObject>(entityDescription: NSEntityDescription, dictionary: [String : AnyObject], error: NSErrorPointer) -> T? {
        switch entityDescription.identifyingAttribute(error)?.preferredValueFromDictionary(dictionary) {
        case let .Some(.Some(value)):
            // Optional contains ImportableValue with some value
            let existingObject: T? = findEntityByIdentifyingAttribute(entityDescription, identifyingValue: value, error: error)
            if let object = existingObject ?? create(entityDescription) {
                if (object.importDictionary(dictionary, error: error)) {
                    return object
                } else if (nil == existingObject) {
                    // Delete object if import failed and we created the object just for importing
                    delete(object, error: error)
                }
            }

        case .Some:
            // Optional contains ImportableValue with .Null or .None value
            return nil

        case .None:
            // Optional no ImportableValue
            return nil
        }

        return nil
    }

    /// Find entity based on the identifying attribute
    func findEntityByIdentifyingAttribute<T:NSManagedObject>(entityDescription: NSEntityDescription, identifyingValue: AnyObject, error: NSErrorPointer) -> T? {
        if let identifyingAttribute = entityDescription.identifyingAttribute(error) {
            let predicate = NSPredicate(format: "%K = %@", argumentArray: [identifyingAttribute.name, identifyingValue])
            if let objects: [T] = find(entityDescription, predicate: predicate, sortDescriptors: nil, limit: nil, error: error) {
                if (objects.count > 1) {
                    if nil != error {
                        error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnexpectedNumberOfResults.rawValue, userInfo: [NSLocalizedDescriptionKey: "Expected 0...1 result, got \(objects.count) results"])
                    }
                } else {
                    return objects.first
                }
            }
        }

        return nil
    }
}
