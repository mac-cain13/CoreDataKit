//
//  NSManagedObjectContext+CoreDataKit.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import "NSManagedObjectContext+CoreDataKit.h"

@implementation NSManagedObjectContext (CoreDataKit)

+ (NSManagedObjectContext *)CDK_contextWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSAssert(persistentStoreCoordinator, @"Persistent store coordinator is mandatory");

    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext performBlockAndWait:^{
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    }];

    return managedObjectContext;
}

- (NSManagedObjectContext *)CDK_childContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType
{
    NSAssert(NSConfinementConcurrencyType != concurrencyType, @"NSConfinementConcurrencyType shouldn't be used as concurrency type");

    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    managedObjectContext.parentContext = self;
#warning Should make sure we always obtain permanent IDs when saving

    return managedObjectContext;
}

@end
