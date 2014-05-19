//
//  NSManagedObject+CoreDataKit.h
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 18-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (CoreDataKit)

///---------------
/// @name Creating
///---------------

/**
 Looks up the entity description for this class in the given `NSManagedObjectContext`.

 @param contextOrNil `NSManagedObjectContext` to use for lookup or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`

 @return Entity description for this class
 */
+ (NSEntityDescription *)CDK_entityDescriptionInContext:(NSManagedObjectContext *)contextOrNil;

+ (instancetype)CDK_createInContext:(NSManagedObjectContext *)contextOrNil;

///--------------
/// @name Finding
///--------------

- (instancetype)CDK_findInContext:(NSManagedObjectContext *)context;

+ (NSArray *)CDK_findAllSortedBy:(NSArray *)sortDescriptorsOrNil
                       inContext:(NSManagedObjectContext *)contextOrNil;

+ (NSArray *)CDK_findWithPredicate:(NSPredicate *)predicateOrNil
                            sortBy:(NSArray *)sortDescriptorsOrNil
                             limit:(NSUInteger)limitOrZero
                         inContext:(NSManagedObjectContext *)contextOrNil;

+ (instancetype)CDK_findFirstWithPredicate:(NSPredicate *)predicateOrNil
                                    sortBy:(NSArray *)sortDescriptorsOrNil
                                 inContext:(NSManagedObjectContext *)contextOrNil;

+ (instancetype)CDK_findFirstOrCreateWithPredicate:(NSPredicate *)predicateOrNil
                                            sortBy:(NSArray *)sortDescriptorsOrNil
                                         inContext:(NSManagedObjectContext *)contextOrNil;

///---------------
/// @name Counting
///---------------

+ (NSUInteger)CDK_countAllInContext:(NSManagedObjectContext *)contextOrNil;

+ (NSArray *)CDK_countWithPredicate:(NSPredicate *)predicateOrNil
                          inContext:(NSManagedObjectContext *)contextOrNil;

///---------------
/// @name Deleting
///---------------

+ (void)CDK_deleteAllInContext:(NSManagedObjectContext *)contextOrNil;

+ (void)CDK_deleteWithPredicate:(NSPredicate *)predicateOrNil
                      inContext:(NSManagedObjectContext *)contextOrNil;

- (void)CDK_deleteInContext:(NSManagedObjectContext *)contextOrNil;

///---------------------------------
/// @name Fetched Results Controller
///---------------------------------

+ (NSFetchedResultsController *)CDK_controllerWithPredicate:(NSPredicate *)predicateOrNil
                                                     sortBy:(NSArray *)sortDescriptorsOrNil
                                                      limit:(NSUInteger)limitOrZero
                                         sectionNameKeyPath:(NSString *)sectionNameKeyPathOrNil
                                                  cacheName:(NSString *)cacheNameOrNil
                                                   delegate:(id<NSFetchedResultsControllerDelegate>)delegateOrNil
                                                  inContext:(NSManagedObjectContext *)contextOrNil;

@end
