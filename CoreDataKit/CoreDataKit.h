//
//  CoreDataKit.h
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 15-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

#import "CDKTypes.h"

/**
 `CoreDataKit` helps with setup of the CoreData stack and provides some high level convenience methods like save helpers.
 */
@interface CoreDataKit : NSObject

/**
 Persistent store coordinator that is used as default for all CoreDataKit actions, is created during invocation of one of the setup methods.
 */
@property (atomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 Root context that is directly associated with the `persistentStoreCoordinator` and does it work on a background queue, is created during invocation of one of the setup methods.
 */
@property (atomic, strong, readonly) NSManagedObjectContext *rootContext;

/**
 Context with concurrency type `NSMainQueueConcurrencyType` for use on the main thread, is created during invocation of one of the setup methods and has `rootContext` set as it's parent context.
 */
@property (atomic, strong, readonly) NSManagedObjectContext *mainThreadContext;

/**
 Returns the shared instance of CoreDataKit.

 @return System wide usable CoreDataKit instance
 */
+ (instancetype)sharedKit;

///------------
/// @name Setup
///------------

/**
 Set up the standard CoreData stack with an automigration enabled SQL store and the default store name.
 
 @see -setupCoreDataStack:automigrating:
 */
- (void)setupAutomigratingCoreDataStack;

/**
 Set up the standard CoreData stack with SQL store.

 @param storeName     Name of the store to load/setup
 @param automigrating Whether automigration should be performed if needed
 */
- (void)setupCoreDataStack:(NSString *)storeName automigrating:(BOOL)automigrating;

/**
 Set up the standard CoreData stack with an in memory store.
 */
- (void)setupCoreDataStackInMemory;

///-------------
/// @name Saving
///-------------

/**
 Shorthand to call save on the shared CoreDataKit instance.

 @param saveBlock  Block that performs the changes on the given context that should be saved
 @param completion Completion block to run after changes are saved
 
 @see -save:completion:
 */
+ (void)save:(CDKSaveBlock)saveBlock completion:(CDKCompletionBlock)completion;

/**
 Performs the given `CDKSaveBlock` on a background thread and persists changes performed on the `NSManagedObjectContext` given to the `CDKSaveBlock` to the persistent store. After saving the `CDKCompletionBlock` block is called and passed a `NSError` object when an error occured or nil when successfull. The `CDKCompletionBlock` will always be called on the main thread.
 
 @discussion It is advised to **never** nest save operations, this will prevent hairpulling, since the given `NSManagedObjectContext`s are not nested it will bite you in the but some time.
 
 @discussion Please remember that `NSManagedObjects` are not threadsafe and your block is performed on another thread and `NSManagedObjectContext`. Make sure to **always** convert your `NSManagedObjects` to the given `NSManagedObjectContext` with `[NSManagedObjects CDK_inContext:]` or by looking up the `NSManagedObjectID` in the given context. This prevents disappearing data, which in turn prevents a lot of swearing.

 @param saveBlock  Block that performs the changes on the given context that should be saved
 @param completion Completion block to run after changes are saved
 */
- (void)save:(CDKSaveBlock)saveBlock completion:(CDKCompletionBlock)completion;

@end
