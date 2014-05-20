//
//  NSManagedObject+CoreDataKit.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 18-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import "NSManagedObject+CoreDataKit.h"
#import "CoreDataKit.h"
#import "CDKDebugger.h"

@implementation NSManagedObject (CoreDataKit)

#pragma mark Creating

+ (NSEntityDescription *)CDK_entityDescriptionInContext:(NSManagedObjectContext *)contextOrNil
{
    NSManagedObjectContext *context = (contextOrNil) ?: [CoreDataKit sharedKit].rootContext;

    return [NSEntityDescription entityForName:NSStringFromClass([self class])
                       inManagedObjectContext:context];
}

+ (instancetype)CDK_createInContext:(NSManagedObjectContext *)contextOrNil
{
    return nil;
}

#pragma mark Finding

- (instancetype)CDK_findInContext:(NSManagedObjectContext *)context
{
    return nil;
}

+ (NSArray *)CDK_findAllSortedBy:(NSArray *)sortDescriptorsOrNil
                       inContext:(NSManagedObjectContext *)contextOrNil
{
    return [self CDK_findWithPredicate:nil sortBy:sortDescriptorsOrNil limit:0 inContext:contextOrNil];
}

+ (NSArray *)CDK_findWithPredicate:(NSPredicate *)predicateOrNil
                            sortBy:(NSArray *)sortDescriptorsOrNil
                             limit:(NSUInteger)limitOrZero
                         inContext:(NSManagedObjectContext *)contextOrNil
{
    NSManagedObjectContext *context = (contextOrNil) ?: [CoreDataKit sharedKit].rootContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[self class] CDK_entityDescriptionInContext:context];
    fetchRequest.predicate = predicateOrNil;
    fetchRequest.sortDescriptors = sortDescriptorsOrNil;
    fetchRequest.fetchLimit = limitOrZero;

    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    CDKHandleError(error);
    return fetchedObjects;
}

+ (instancetype)CDK_findFirstWithPredicate:(NSPredicate *)predicateOrNil
                                    sortBy:(NSArray *)sortDescriptorsOrNil
                                 inContext:(NSManagedObjectContext *)contextOrNil
{
    NSManagedObjectContext *context = (contextOrNil) ?: [CoreDataKit sharedKit].rootContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[self class] CDK_entityDescriptionInContext:context];
    fetchRequest.predicate = predicateOrNil;
    fetchRequest.sortDescriptors = sortDescriptorsOrNil;
    fetchRequest.fetchLimit = 1;
    fetchRequest.returnsObjectsAsFaults = NO;

    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    CDKHandleError(error);
    return fetchedObjects.firstObject;
}

+ (instancetype)CDK_findFirstOrCreateWithPredicate:(NSPredicate *)predicateOrNil
                                            sortBy:(NSArray *)sortDescriptorsOrNil
                                         inContext:(NSManagedObjectContext *)contextOrNil
{
    NSManagedObject *object = [self CDK_findFirstWithPredicate:predicateOrNil
                                                        sortBy:sortDescriptorsOrNil
                                                     inContext:contextOrNil];

    if (!object) {
        object = [self CDK_createInContext:contextOrNil];
    }

    return object;
}

#pragma mark Counting

+ (NSUInteger)CDK_countAllInContext:(NSManagedObjectContext *)contextOrNil
{
    return 0;
}

+ (NSUInteger)CDK_countWithPredicate:(NSPredicate *)predicateOrNil
                           inContext:(NSManagedObjectContext *)contextOrNil
{
    return 0;
}

#pragma mark Deleting

+ (void)CDK_deleteAllInContext:(NSManagedObjectContext *)contextOrNil
{
    return;
}

+ (void)CDK_deleteWithPredicate:(NSPredicate *)predicateOrNil
                      inContext:(NSManagedObjectContext *)contextOrNil
{
    return;
}

- (void)CDK_deleteInContext:(NSManagedObjectContext *)contextOrNil
{
    return;
}

#pragma mark Fetched Results Controller

+ (NSFetchedResultsController *)CDK_controllerWithPredicate:(NSPredicate *)predicateOrNil
                                                     sortBy:(NSArray *)sortDescriptorsOrNil
                                                      limit:(NSUInteger)limitOrZero
                                         sectionNameKeyPath:(NSString *)sectionNameKeyPathOrNil
                                                  cacheName:(NSString *)cacheNameOrNil
                                                   delegate:(id<NSFetchedResultsControllerDelegate>)delegateOrNil
                                                  inContext:(NSManagedObjectContext *)contextOrNil
{
    return nil;
}

+ (NSFetchedResultsController *)CDK_controllerWithFetchRequest:(NSFetchRequest *)fetchRequest
                                            sectionNameKeyPath:(NSString *)sectionNameKeyPathOrNil
                                                     cacheName:(NSString *)cacheNameOrNil
                                                      delegate:(id<NSFetchedResultsControllerDelegate>)delegateOrNil
                                                     inContext:(NSManagedObjectContext *)contextOrNil
{
    return nil;
}

@end
