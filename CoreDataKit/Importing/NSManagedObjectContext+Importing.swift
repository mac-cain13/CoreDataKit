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
    public func importEntity<T: NSManagedObject where T:NamedManagedObject>(entity: T.Type, dictionary: [String : AnyObject]) -> Result<T> {
        switch entityDescription(entity) {
        case let .Success(boxedDescription):
            return importEntity(boxedDescription.value, dictionary: dictionary)

        case let .Failure(boxedError):
            return .Failure(boxedError)
        }
    }

    /// Import dictionary into an entity based on entity description
    func importEntity<T:NSManagedObject>(entityDescription: NSEntityDescription, dictionary: [String : AnyObject]) -> Result<T> {

        switch entityDescription.identifyingAttribute() {
        case let .Success(boxedAttribute):
            switch boxedAttribute.value.preferredValueFromDictionary(dictionary) {
            case let .Some(value):
                let importObjectResult: Result<T> = objectForImport(entityDescription, identifyingValue: value)
                switch importObjectResult {
                case let .Success(boxedImportedObject):
                    switch boxedImportedObject.value.importDictionary(dictionary) {
                    case .Success:
                        return .Success(boxedImportedObject)

                    case let .Failure(error):
                        return .Failure(error)
                    }

                case let .Failure(boxedError):
                    return .Failure(boxedError)
                }

            case .Null:
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "Value 'null' in import dictionary for identifying atribute '\(entityDescription.name).\(boxedAttribute.value.name)', dictionary: \(dictionary)"])
                return Result(error)

            case .None:
                let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.InvalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "No value in import dictionary for identifying atribute '\(entityDescription.name).\(boxedAttribute.value.name)', dictionary: \(dictionary)"])
                return Result(error)
            }

        case let .Failure(boxedError):
            return .Failure(boxedError)
        }
    }

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

    /// Find entity based on the identifying attribute
    func findEntityByIdentifyingAttribute<T:NSManagedObject>(entityDescription: NSEntityDescription, identifyingValue: AnyObject) -> Result<T?> {
        switch entityDescription.identifyingAttribute() {
        case let .Success(boxedAttribute):
            let predicate = NSPredicate(format: "%K = %@", argumentArray: [boxedAttribute.value.name, identifyingValue])
            switch find(entityDescription, predicate: predicate, sortDescriptors: nil, limit: nil) {
            case let .Success(boxedResults):
                if (boxedResults.value.count > 1) {
                    let error = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnexpectedNumberOfResults.rawValue, userInfo: [NSLocalizedDescriptionKey: "Expected 0...1 result, got \(boxedResults.value.count) results"])
                    return Result(error)
                } else if let firstResult = boxedResults.value.first {
                    return Result(firstResult as? T)
                } else {
                    return Result(nil)
                }

            case let .Failure(boxedError):
                return .Failure(boxedError)
            }

        case let .Failure(boxedError):
            return .Failure(boxedError)
        }
    }
}
