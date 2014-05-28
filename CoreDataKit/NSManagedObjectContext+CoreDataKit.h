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
 Performs the given block in the background and persists changes performed on the receiving `NSManagedObjectContext`. After saving the `CDKCompletionBlock` block is called and passed a `NSError` object when an error occured or nil when successfull. The `CDKCompletionBlock` will always be called on the main thread.

 @discussion It is advised to **never** nest save operations, this will prevent hairpulling.

 @discussion Please remember that `NSManagedObjects` are not threadsafe. Make sure to **always** convert your `NSManagedObjects` to the receiving context by using `[NSManagedObjects CDK_inContext:]` or by looking up the `NSManagedObjectID` in the given context. This prevents disappearing data, which in turn prevents a lot of swearing.

 @param block      Block that performs the changes on the given context that should be saved
 @param completion Completion block to run after changes are saved
 
 @see -CDK_performBlockAndSaveToPersistentStore:completion:
 */
- (void)CDK_performBlockAndSaveToParentContext:(void (^)())block completion:(CDKCompletionBlock)completion;

/**
 Performs the given block in the background and persists changes performed on the receiving `NSManagedObjectContext`all the way up to the persistent store. After saving the `CDKCompletionBlock` block is called and passed a `NSError` object when an error occured or nil when successfull. The `CDKCompletionBlock` will always be called on the main thread.

 @discussion It is advised to **never** nest save operations, this will prevent hairpulling.

 @discussion Please remember that `NSManagedObjects` are not threadsafe. Make sure to **always** convert your `NSManagedObjects` to the receiving context by using `[NSManagedObjects CDK_inContext:]` or by looking up the `NSManagedObjectID` in the given context. This prevents disappearing data, which in turn prevents a lot of swearing.

 @param block      Block that performs the changes on the given context that should be saved
 @param completion Completion block to run after changes are saved

 @see -CDK_performBlockAndSaveToParentContext:completion:
 */
- (void)CDK_performBlockAndSaveToPersistentStore:(void (^)())block completion:(CDKCompletionBlock)completion;

/**
 Obtains permanent object IDs for all objects inserted in this context. This ensures that the object has an object ID that you can lookup in an other context.
 
 @discussion This is done automatically by `NSManagedObjectContext`s that are created by CoreDataKit right before saving. So usually you don't have to use this yourself.
 */
- (void)CDK_obtainPermanentIDsForInsertedObjects;

@end
