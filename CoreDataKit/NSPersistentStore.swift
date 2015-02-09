//
//  NSPersistentStore.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 07-07-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSPersistentStore
{
    /**
    Creates URL for SQLite store with the given store name.

    :param: storeName Store name to build URL for

    :returns: URL with the location of the store
    */
    public class func URLForSQLiteStoreName(storeName: String) -> NSURL?
    {
        assert(count(storeName) > 0, "Store name must be longer then zero characters.")

        let optionalSupportDirectoryURL = NSFileManager.defaultManager().URLForDirectory(.ApplicationSupportDirectory, inDomain: .AllDomainsMask, appropriateForURL: nil, create: true, error: nil)

        if let supportDirectoryURL = optionalSupportDirectoryURL {
            return supportDirectoryURL.URLByAppendingPathComponent(storeName + ".sqlite", isDirectory: false)
        }

        return nil
    }
}
