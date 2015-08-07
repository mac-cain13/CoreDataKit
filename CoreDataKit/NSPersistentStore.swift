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

    - parameter storeName: Store name to build URL for

    - returns: URL with the location of the store
    */
    public class func URLForSQLiteStoreName(storeName: String) -> NSURL?
    {
        assert(storeName.characters.count > 0, "Store name must be longer then zero characters.")

        do {
            let supportDirectoryURL = try NSFileManager.defaultManager().URLForDirectory(.ApplicationSupportDirectory, inDomain: .AllDomainsMask, appropriateForURL: nil, create: true)
            return supportDirectoryURL.URLByAppendingPathComponent(storeName + ".sqlite", isDirectory: false)
        } catch _ {
            return nil
        }
    }
}
