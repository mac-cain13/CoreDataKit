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
    public func importEntity<T: NSManagedObject where T:NamedManagedObject>(entity: T.Type, dictionary: [String : AnyObject], error: NSErrorPointer) -> T? {
        // Look up the identifying attribute
        if let entityDescription = entityDescription(entity, error: error)
        {
            if let identifyingAttribute = entityDescription.identifyingAttribute
            {
                if let identifyingAttributeValue: AnyObject = identifyingAttribute.preferredValueFromDictionary(dictionary)
                {
                    let predicate = NSPredicate(format: "%K = %@", argumentArray: [identifyingAttribute.name, identifyingAttributeValue])
                    if let objects = find(entity, predicate: predicate, sortDescriptors: nil, limit: nil, error: error)
                    {
                        if (objects.count > 1)
                        {
                            if nil != error {
                                error.memory = NSError(domain: CoreDataKitErrorDomain, code: CoreDataKitErrorCode.UnexpectedNumberOfResults.rawValue, userInfo: [NSLocalizedDescriptionKey: "Expected 0...1 result, got \(objects.count) results"])
                            }
                        }
                        else if let object = objects.first ?? create(entity, error: error)
                        {
                            if (object.importDictionary(dictionary, error: error)) {
                                return object
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
}
