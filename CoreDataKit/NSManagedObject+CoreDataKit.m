//
//  NSManagedObject+CoreDataKit.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 18-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import "NSManagedObject+CoreDataKit.h"
#import "NSManagedObjectContext+CoreDataKit.h"
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
    NSManagedObjectContext *context = (contextOrNil) ?: [CoreDataKit sharedKit].rootContext;
    return [[self alloc] initWithEntity:[self CDK_entityDescriptionInContext:context]
         insertIntoManagedObjectContext:context];
}

#pragma mark Finding

+ (NSFetchRequest *)CDK_requestInContext:(NSManagedObjectContext *)contextOrNil
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [self CDK_entityDescriptionInContext:contextOrNil];
    return fetchRequest;
}

- (instancetype)CDK_findInContext:(NSManagedObjectContext *)context
{
    NSAssert(context, @"Managed object context cannot be nil");

    NSManagedObject *fetchedObject = nil;
    NSError *error = nil;

    // First make sure we have a permanent ID for this object
    if (self.objectID.isTemporaryID) {
        [self.managedObjectContext obtainPermanentIDsForObjects:@[self] error:&error];
        CDKHandleError(error);
    }

    // If no errors so far, fetch this object in the given context
    if (!error) {
        fetchedObject = [context existingObjectWithID:self.objectID error:&error];
        CDKHandleError(error);
    }

    return fetchedObject;
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

    NSFetchRequest *fetchRequest = [self CDK_requestInContext:context];
    fetchRequest.predicate = predicateOrNil;
    fetchRequest.sortDescriptors = sortDescriptorsOrNil;
    fetchRequest.fetchLimit = limitOrZero;
    fetchRequest.returnsObjectsAsFaults = YES;

    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    CDKHandleError(error);
    return fetchedObjects;
}

+ (instancetype)CDK_findFirstWithPredicate:(NSPredicate *)predicateOrNil
                                    sortBy:(NSArray *)sortDescriptorsOrNil
                                 inContext:(NSManagedObjectContext *)contextOrNil
{
    // Note; Would love to use `returnsObjectsAsFaults` here to not fetch a fault, but it seems buggy in at least iOS 7
    // See: http://stackoverflow.com/questions/12780509/does-coredata-always-respect-returnobjectsasfaults?rq=1
    return [self CDK_findWithPredicate:predicateOrNil
                                sortBy:sortDescriptorsOrNil
                                 limit:1
                             inContext:contextOrNil].firstObject;
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
    return [self CDK_countWithPredicate:nil inContext:contextOrNil];
}

+ (NSUInteger)CDK_countWithPredicate:(NSPredicate *)predicateOrNil
                           inContext:(NSManagedObjectContext *)contextOrNil
{
    NSManagedObjectContext *context = (contextOrNil) ?: [CoreDataKit sharedKit].rootContext;

    NSFetchRequest *fetchRequest = [self CDK_requestInContext:context];
    fetchRequest.predicate = predicateOrNil;

    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];

    CDKHandleError(error);
    return count;
}

#pragma mark Deleting

+ (void)CDK_deleteAllInContext:(NSManagedObjectContext *)contextOrNil
{
    return [self CDK_deleteWithPredicate:nil inContext:contextOrNil];
}

+ (void)CDK_deleteWithPredicate:(NSPredicate *)predicateOrNil
                      inContext:(NSManagedObjectContext *)contextOrNil
{
    NSManagedObjectContext *context = (contextOrNil) ?: [CoreDataKit sharedKit].rootContext;

    NSFetchRequest *fetchRequest = [self CDK_requestInContext:context];
    fetchRequest.predicate = predicateOrNil;
    fetchRequest.includesPropertyValues = NO;

    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    CDKHandleError(error);

    [fetchedObjects enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
        [obj CDK_delete];
    }];
}

- (void)CDK_delete
{
    [self.managedObjectContext CDK_obtainPermanentIDsForInsertedObjects];

    [self.managedObjectContext deleteObject:self];
}

#pragma mark Fetched Results Controller

+ (NSFetchedResultsController *)CDK_controllerWithPredicate:(NSPredicate *)predicateOrNil
                                                     sortBy:(NSArray *)sortDescriptors
                                                      limit:(NSUInteger)limitOrZero
                                         sectionNameKeyPath:(NSString *)sectionNameKeyPathOrNil
                                                  cacheName:(NSString *)cacheNameOrNil
                                                   delegate:(id<NSFetchedResultsControllerDelegate>)delegateOrNil
                                                  inContext:(NSManagedObjectContext *)contextOrNil
{
    NSManagedObjectContext *context = (contextOrNil) ?: [CoreDataKit sharedKit].rootContext;

    NSFetchRequest *fetchRequest = [self CDK_requestInContext:context];
    fetchRequest.predicate = predicateOrNil;
    fetchRequest.sortDescriptors = sortDescriptors;
    fetchRequest.fetchLimit = limitOrZero;

    return [self CDK_controllerWithFetchRequest:fetchRequest
                             sectionNameKeyPath:sectionNameKeyPathOrNil
                                      cacheName:cacheNameOrNil
                                       delegate:delegateOrNil
                                      inContext:context];
}

+ (NSFetchedResultsController *)CDK_controllerWithFetchRequest:(NSFetchRequest *)fetchRequest
                                            sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                     cacheName:(NSString *)cacheNameOrNil
                                                      delegate:(id<NSFetchedResultsControllerDelegate>)delegateOrNil
                                                     inContext:(NSManagedObjectContext *)contextOrNil
{
    NSManagedObjectContext *context = (contextOrNil) ?: [CoreDataKit sharedKit].rootContext;

    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:context
                                                                            sectionNameKeyPath:sectionNameKeyPath
                                                                                     cacheName:cacheNameOrNil];
    frc.delegate = delegateOrNil;

    return frc;
}

@end
