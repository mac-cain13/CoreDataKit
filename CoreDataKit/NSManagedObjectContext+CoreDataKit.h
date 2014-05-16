//
//  NSManagedObjectContext+CoreDataKit.h
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (CoreDataKit)

/**
 Create a new 'root' `NSManagedObjectContext` that is directly associated with the given `NSPersistentStoreCoordinator`, will be of type `NSPrivateQueueConcurrencyType`.

 @param persistentStoreCoordinator Persistent store coordinator to associate with

 @return The created managed object context
 */
+ (NSManagedObjectContext *)CDK_contextWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/**
 Create a new 'child' `NSManagedObjectContext` that receiver of this message set as parent context to save to.

 @param concurrencyType Concurrency type to use, should be `NSPrivateQueueConcurrencyType` or `NSMainQueueConcurrencyType`

 @return Newly created managed object context
 */
- (NSManagedObjectContext *)CDK_childContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

@end
