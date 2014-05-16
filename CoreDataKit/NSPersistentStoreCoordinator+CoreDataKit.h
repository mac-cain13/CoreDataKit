//
//  NSPersistentStoreCoordinator+CoreDataKit.h
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinator (CoreDataKit)

/**
 Creates URL for SQLite store with the given store name.

 @param storeName Store name to build URL for

 @return URL with the location of the store
 */
+ (NSURL *)CDK_URLForStoreName:(NSString *)storeName;

/**
 Add a SQLite `NSPersistentStore` optionally automigration.

 @param storeURL      Location of the SQLite store
 @param automigrating Whether automigration should be performed if needed
 */
- (void)CDK_addSQLiteStoreWithURL:(NSURL *)storeURL automigrating:(BOOL)automigrating;

@end
