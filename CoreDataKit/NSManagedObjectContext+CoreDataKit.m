//
//  NSManagedObjectContext+CoreDataKit.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import "NSManagedObjectContext+CoreDataKit.h"
#import "CDKDebugger.h"

@implementation NSManagedObjectContext (CoreDataKit)

#pragma mark Context creation

+ (instancetype)CDK_contextWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSAssert(persistentStoreCoordinator, @"Persistent store coordinator is mandatory");

    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext performBlockAndWait:^{
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    }];

    // Make sure permanent IDs are obtained before saving
    [[NSNotificationCenter defaultCenter] addObserver:managedObjectContext
                                             selector:@selector(CDK_obtainPermanentIDsForInsertedObjects)
                                                 name:NSManagedObjectContextWillSaveNotification
                                               object:managedObjectContext];

    return managedObjectContext;
}

- (instancetype)CDK_childContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType
{
    NSAssert(NSConfinementConcurrencyType != concurrencyType, @"NSConfinementConcurrencyType shouldn't be used as concurrency type");

    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    managedObjectContext.parentContext = self;

    // Make sure permanent IDs are obtained before saving
    [[NSNotificationCenter defaultCenter] addObserver:managedObjectContext
                                             selector:@selector(CDK_obtainPermanentIDsForInsertedObjects)
                                                 name:NSManagedObjectContextWillSaveNotification
                                               object:managedObjectContext];

    return managedObjectContext;
}

#pragma mark Saving

- (void)CDK_saveToPersistentStore:(CDKCompletionBlock)completion
{
    [self performBlock:^{
        // Perform save
        NSError *error = nil;
        [self save:&error];

        if (error || !self.parentContext)
        {
            // If error or no more parent contexts call completion handler
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
        }
        else
        {
            // Continue to save one level up
            [self.parentContext CDK_saveToPersistentStore:completion];
        }
    }];
}

- (void)CDK_saveToParentContext:(CDKCompletionBlock)completion
{
    [self performBlock:^{
        // Perform save
        NSError *error = nil;
        [self save:&error];

        // Call completion handler
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    }];
}

- (void)CDK_obtainPermanentIDsForInsertedObjects
{
    if (self.insertedObjects.count)
    {
        NSError *error = nil;
        [self obtainPermanentIDsForObjects:self.insertedObjects.allObjects error:&error];
        CDKHandleError(error);
    }
}

@end
