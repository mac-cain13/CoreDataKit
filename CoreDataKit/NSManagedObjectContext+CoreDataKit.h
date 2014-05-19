//
//  NSManagedObjectContext+CoreDataKit.h
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CDKTypes.h"

@interface NSManagedObjectContext (CoreDataKit)

///-----------------------
/// @name Context creation
///-----------------------

/**
 Create a new 'root' `NSManagedObjectContext` that is directly associated with the given `NSPersistentStoreCoordinator`, will be of type `NSPrivateQueueConcurrencyType`.
 
 @discussion The context will also obtain permanent IDs for `NSManagedObject`s before saving. This will prevent problems where you can't convert objects between two `NSManagedObjectContext`s, so it's advised to create context using this method.

 @param persistentStoreCoordinator Persistent store coordinator to associate with

 @return The created managed object context
 */
+ (instancetype)CDK_contextWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/**
 Create a new 'child' `NSManagedObjectContext` that receiver of this message set as parent context to save to.
 
 @discussion The context will also obtain permanent IDs for `NSManagedObject`s before saving. This will prevent problems where you can't convert objects between two `NSManagedObjectContext`s, so it's advised to create context using this method.

 @param concurrencyType Concurrency type to use, must be `NSPrivateQueueConcurrencyType` or `NSMainQueueConcurrencyType`

 @return Newly created managed object context
 */
- (instancetype)CDK_childContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

///-------------
/// @name Saving
///-------------

/**
 Asynchronously saves the context all the way up to the persistent store.

 @param completion Will be performed on the main thread after save and is passed the error of the save action if any

 @see -CDK_saveToParentContext:
 */
- (void)CDK_saveToPersistentStore:(CDKCompletionBlock)completion;

/**
 Asynchronously saves the context to it's parent context.

 @param completion Will be performed on the main thread after save and is passed the error of the save action if any
 
 @see -CDK_saveToPersistentStore:
 */
- (void)CDK_saveToParentContext:(CDKCompletionBlock)completion;

/**
 Obtains permanent object IDs for all objects inserted in this context. This ensures that the object has an object ID that you can lookup in an other context.
 
 @discussion This is done automatically by `NSManagedObjectContext`s that are created by CoreDataKit right before saving. So usually you don't have to use this yourself.
 */
- (void)CDK_obtainPermanentIDsForInsertedObjects;

@end
