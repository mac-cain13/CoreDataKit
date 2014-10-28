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
    
    :see: Importing documentation at [TODO]

    :param: entity      Type of entity to import
    :param: dictionary  Data to import
    
    :returns: Result with managed object of the given entity type with the data imported on it
    */
    public func importEntity<T: NSManagedObject where T:NamedManagedObject>(entity: T.Type, dictionary: [String : AnyObject]) -> Result<T> {
        return entityDescription(entity).flatMap { self.importEntity($0, dictionary: dictionary) }
    }

    /**
    Import dictionary into an entity based on entity description, will do lookups in the context to find the object to import

    :see: Importing documentation at [TODO]

    :param: entityDescription Description of entity to import
    :param: dictionary        Data to import

    :returns: Result with managed object of the given entity type with the data imported on it
    */
    func importEntity<T:NSManagedObject>(entityDescription: NSEntityDescription, dictionary: [String : AnyObject]) -> Result<T> {

        return entityDescription.identifyingAttribute().flatMap { identifyingAttribute in
            switch identifyingAttribute.preferredValueFromDictionary(dictionary) {
            case let .Some(value):
                let importObjectResult: Result<T> = self.objectForImport(entityDescription, identifyingValue: value)
                return importObjectResult.flatMap { object in
                    return object.importDictionary(dictionary).map { object }
                }

            case .Null:
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "Value 'null' in import dictionary for identifying atribute '\(entityDescription.name).\(identifyingAttribute.name)', dictionary: \(dictionary)"])
                return Result(error)

            case .None:
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "No value in import dictionary for identifying atribute '\(entityDescription.name).\(identifyingAttribute.name)', dictionary: \(dictionary)"])
                return Result(error)
            }
        }
    }

    /**
    Find or create an instance of this managed object to use for import
    
    :param: entityDescription Description of entity to import
    :param: identifyingValue  The identifying value of the object
    
    :return: Result with the object to perform the import on
    */
    private func objectForImport<T:NSManagedObject>(entityDescription: NSEntityDescription, identifyingValue: AnyObject) -> Result<T> {
        let findResult: Result<T?> = findEntityByIdentifyingAttribute(entityDescription, identifyingValue: identifyingValue)
        switch findResult {
        case let .Success(boxedObject):
            if let existingObject = boxedObject.value {
                return Result(existingObject)
            } else {
                return create(entityDescription)
            }

        case .Failure:
            return create(entityDescription)
        }
    }

    /**
    Find entity based on the identifying attribute

    :param: entityDescription Description of entity to find
    :param: identifyingValue  The identifying value of the object
    
    :returns: Result with the optional object that is found, nil on not found
    */
    func findEntityByIdentifyingAttribute<T:NSManagedObject>(entityDescription: NSEntityDescription, identifyingValue: AnyObject) -> Result<T?> {

        return entityDescription.identifyingAttribute().flatMap { identifyingAttribute in
            let predicate = NSPredicate(format: "%K = %@", argumentArray: [identifyingAttribute.name, identifyingValue])
            return self.find(entityDescription, predicate: predicate).flatMap {
                if ($0.count > 1) {
                    let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnexpectedNumberOfResults.rawValue, userInfo: [NSLocalizedDescriptionKey: "Expected 0...1 result, got \($0.count) results"])
                    return Result(error)
                } else if let firstResult = $0.first {
                    return Result(firstResult as? T)
                } else {
                    return Result(nil)
                }
            }
        }
    }
}
