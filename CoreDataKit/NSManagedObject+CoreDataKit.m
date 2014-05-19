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

+ (NSEntityDescription *)CDK_entityDescriptionInContext:(NSManagedObjectContext *)contextOrNil
{
    NSManagedObjectContext *context = (contextOrNil) ?: [CoreDataKit sharedKit].rootContext;

    return [NSEntityDescription entityForName:NSStringFromClass([self class])
                       inManagedObjectContext:context];
}

#pragma mark Create

#warning Untested
- (instancetype)CDK_createInContext:(NSManagedObjectContext *)contextOrNil
{
    return nil;
}

#pragma mark Find

#warning Untested
- (NSArray *)CDK_findAllSortedBy:(NSArray *)sortDescriptorsOrNil
                       inContext:(NSManagedObjectContext *)contextOrNil
{
    return [self CDK_findWithPredicate:nil sortBy:sortDescriptorsOrNil limit:0 inContext:contextOrNil];
}

#warning Untested
- (NSArray *)CDK_findWithPredicate:(NSPredicate *)predicateOrNil
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

#warning Untested
- (instancetype)CDK_findFirstWithPredicate:(NSPredicate *)predicateOrNil
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

#warning Untested
- (instancetype)CDK_findFirstOrCreateWithPredicate:(NSPredicate *)predicateOrNil
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

@end
