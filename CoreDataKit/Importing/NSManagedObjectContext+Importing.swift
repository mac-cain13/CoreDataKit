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

    - parameter entity:      Type of entity to import
    - parameter dictionary:  Data to import
    
    - returns: Result with managed object of the given entity type with the data imported on it
    */
    public func importEntity<T: NSManagedObject where T:NamedManagedObject>(entity: T.Type, dictionary: [String : AnyObject]) throws -> T {
        let desc = try entityDescription(entity)
        return try self.importEntity(desc, dictionary: dictionary)
    }

    /**
    Import dictionary into an entity based on entity description, will do lookups in the context to find the object to import

    :see: Importing documentation at [TODO]

    - parameter entityDescription: Description of entity to import
    - parameter dictionary:        Data to import

    - returns: Result with managed object of the given entity type with the data imported on it
    */
    func importEntity<T:NSManagedObject>(entityDescription: NSEntityDescription, dictionary: [String : AnyObject]) throws -> T {

        let identifyingAttribute = try entityDescription.identifyingAttribute()
        switch identifyingAttribute.preferredValueFromDictionary(dictionary) {
        case let .Some(value):
            let object: T = try self.objectForImport(entityDescription, identifyingValue: value)
            try object.importDictionary(dictionary)
            return object

        case .Null:
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "Value 'null' in import dictionary for identifying atribute '\(entityDescription.name).\(identifyingAttribute.name)', dictionary: \(dictionary)"])
            throw error

        case .None:
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "No value in import dictionary for identifying atribute '\(entityDescription.name).\(identifyingAttribute.name)', dictionary: \(dictionary)"])
            throw error
        }
    }

    /**
    Find or create an instance of this managed object to use for import
    
    - parameter entityDescription: Description of entity to import
    - parameter identifyingValue:  The identifying value of the object
    
    :return: Result with the object to perform the import on
    */
    private func objectForImport<T:NSManagedObject>(entityDescription: NSEntityDescription, identifyingValue: AnyObject) throws -> T {
        do {
          if let object: T = try findEntityByIdentifyingAttribute(entityDescription, identifyingValue: identifyingValue) {
                return object
            }
        }
        catch {
        }

        return try create(entityDescription)
    }

    /**
    Find entity based on the identifying attribute

    - parameter entityDescription: Description of entity to find
    - parameter identifyingValue:  The identifying value of the object
    
    - returns: Result with the optional object that is found, nil on not found
    */
    func findEntityByIdentifyingAttribute<T:NSManagedObject>(entityDescription: NSEntityDescription, identifyingValue: AnyObject) throws -> T? {

        let identifyingAttribute = try entityDescription.identifyingAttribute()
        let predicate = NSPredicate(format: "%K = %@", argumentArray: [identifyingAttribute.name, identifyingValue])
        let objects = try self.find(entityDescription, predicate: predicate)

        if objects.count > 1 {
            let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnexpectedNumberOfResults.rawValue, userInfo: [NSLocalizedDescriptionKey: "Expected 0...1 result, got \(objects.count) results"])
            throw error
        }

        return objects.first as? T
    }
}
