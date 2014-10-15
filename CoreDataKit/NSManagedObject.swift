//
//  NSManagedObject.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 14-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSManagedObject
{
    class var entityName: String? { get { return nil } }
    class var identifier: String? { get { return nil } }



    public class func entityDescriptionInContext(context: NSManagedObjectContext) -> NSEntityDescription?
    {
        if let entityName = self.entityName {
            return NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
        }

        return nil
    }

    public class func createInContext(context: NSManagedObjectContext) -> Self?
    {
        if let entityDescription = entityDescriptionInContext(context) {
            return self(entity: entityDescription, insertIntoManagedObjectContext: context)
        }

        return nil
    }

    public class func importFromData(dataObject: AnyObject?, inContext: NSManagedObjectContext) -> Self?
    {
        return nil
    }
}
