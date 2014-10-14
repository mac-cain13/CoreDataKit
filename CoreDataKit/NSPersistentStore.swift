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
    public class func URLForStoreName(storeName: String) -> NSURL?
    {
        assert(countElements(storeName) > 0, "Store name must be longer then zero characters.")

        let supportDirectoryURLs = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .AllDomainsMask)

        if let supportDirectoryURL = supportDirectoryURLs.first as? NSURL {
            return supportDirectoryURL.URLByAppendingPathComponent(storeName + ".sqlite", isDirectory: false)
        }

        return nil
    }
}
