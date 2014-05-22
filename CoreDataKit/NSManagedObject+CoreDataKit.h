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

/**
 Creates an entity based on the default CoreDataKit `CDK_entityDescriptionInContext:` in the given context.

 @param contextOrNil `NSManagedObjectContext` to insert the entity in or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`

 @return Newly inserted `NSManagedObject` subclass
 */
+ (instancetype)CDK_createInContext:(NSManagedObjectContext *)contextOrNil;

///--------------
/// @name Finding
///--------------

/**
 Creates a fetch request to fetch enties of the receivers type.
 
 @discussion All of CoreDataKits find, count and delete methods will only find/apply on the `NSManagedObject` subclass the are called on. So `[Car CDK_deleteAllInContext:context]` will delete all `Car` entities in the given context and `[Car CDK_countAllInContext:context]` will count all `Car` entities and subentities in the given context. Other entities are ignored and not touched.
 
 @param contextOrNil  `NSManagedObjectContext` to create the request in or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`

 @return Fetch request ready to fetch entities of the receivers type
 */
+ (NSFetchRequest *)CDK_requestInContext:(NSManagedObjectContext *)contextOrNil;

/**
 Finds this `NSManagedObject` in the given context.

 @discussion This is the preferred method to convert an `NSManagedObject` from one `NSManagedObjectContext` to another. This is often used in `CDKSaveBlock`s to convert an already available entity to the correct context.

 @param context `NSManagedObjectContext` to convert to

 @return The `NSManagedObject` in the given context or `nil` if the entity doesn't exists in the given `NSManagedObjectContext`
 */
- (instancetype)CDK_findInContext:(NSManagedObjectContext *)context;

/**
 Find all entities that are available in the given context.
 
 @discussion All of CoreDataKits find, count and delete methods will only find/apply on the `NSManagedObject` subclass the are called on. So `[Car CDK_deleteAllInContext:context]` will delete all `Car` entities in the given context and `[Car CDK_countAllInContext:context]` will count all `Car` entities and subentities in the given context. Other entities are ignored and not touched.

 @param sortDescriptorsOrNil Array of sort descriptors to order the entities by or nil to not apply sorting
 @param contextOrNil         `NSManagedObjectContext` to search through or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`

 @return `NSArray` of `NSManagedObject` subclasses
 */
+ (NSArray *)CDK_findAllSortedBy:(NSArray *)sortDescriptorsOrNil
                       inContext:(NSManagedObjectContext *)contextOrNil;

/**
 Find entities matching the predicate of this kind that are available in the given context.
 
 @discussion All of CoreDataKits find, count and delete methods will only find/apply on the `NSManagedObject` subclass the are called on. So `[Car CDK_deleteAllInContext:context]` will delete all `Car` entities in the given context and `[Car CDK_countAllInContext:context]` will count all `Car` entities and subentities in the given context. Other entities are ignored and not touched.

 @param predicateOrNil       `NSPredicate` to filter entities on or nil to apply no predicate
 @param sortDescriptorsOrNil Array of sort descriptors to order the entities by or nil to not apply sorting
 @param limitOrZero          Maximum number of entities to fetch or zero to apply no limit
 @param contextOrNil         `NSManagedObjectContext` to search through or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`

 @return `NSArray` of `NSManagedObject` subclasses
 */
+ (NSArray *)CDK_findWithPredicate:(NSPredicate *)predicateOrNil
                            sortBy:(NSArray *)sortDescriptorsOrNil
                             limit:(NSUInteger)limitOrZero
                         inContext:(NSManagedObjectContext *)contextOrNil;

/**
 Find the first entity matching the predicate of this kind respecting the given sort descriptors that is available in the given context.
 
 @discussion All of CoreDataKits find, count and delete methods will only find/apply on the `NSManagedObject` subclass the are called on. So `[Car CDK_deleteAllInContext:context]` will delete all `Car` entities in the given context and `[Car CDK_countAllInContext:context]` will count all `Car` entities and subentities in the given context. Other entities are ignored and not touched.

 @param predicateOrNil       `NSPredicate` to filter entities on or nil to apply no predicate
 @param sortDescriptorsOrNil Array of sort descriptors to order the entities by or nil to not apply sorting
 @param contextOrNil         `NSManagedObjectContext` to search through or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`

 @return The first matching `NSManagedObject` subclasses
 */
+ (instancetype)CDK_findFirstWithPredicate:(NSPredicate *)predicateOrNil
                                    sortBy:(NSArray *)sortDescriptorsOrNil
                                 inContext:(NSManagedObjectContext *)contextOrNil;

/**
 Find the first entity matching the predicate of this kind respecting the given sort descriptors that is available in the given context, if no entity is found one is created and inserted into the given context.
 
 @discussion All of CoreDataKits find, count and delete methods will only find/apply on the `NSManagedObject` subclass the are called on. So `[Car CDK_deleteAllInContext:context]` will delete all `Car` entities in the given context and `[Car CDK_countAllInContext:context]` will count all `Car` entities and subentities in the given context. Other entities are ignored and not touched.

 @param predicateOrNil       `NSPredicate` to filter entities on or nil to apply no predicate
 @param sortDescriptorsOrNil Array of sort descriptors to order the entities by or nil to not apply sorting
 @param contextOrNil         `NSManagedObjectContext` to search through or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`

 @return The first matching or created `NSManagedObject` subclasses
 */
+ (instancetype)CDK_findFirstOrCreateWithPredicate:(NSPredicate *)predicateOrNil
                                            sortBy:(NSArray *)sortDescriptorsOrNil
                                         inContext:(NSManagedObjectContext *)contextOrNil;

///---------------
/// @name Counting
///---------------

/**
 Count all entities in the given context.
 
 @discussion All of CoreDataKits find, count and delete methods will only find/apply on the `NSManagedObject` subclass the are called on. So `[Car CDK_deleteAllInContext:context]` will delete all `Car` entities in the given context and `[Car CDK_countAllInContext:context]` will count all `Car` entities and subentities in the given context. Other entities are ignored and not touched.

 @param contextOrNil `NSManagedObjectContext` to search through or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`

 @return Number of entities
 */
+ (NSUInteger)CDK_countAllInContext:(NSManagedObjectContext *)contextOrNil;

/**
 Count entities matching the given `NSPredicate` in the given context.
 
 @discussion All of CoreDataKits find, count and delete methods will only find/apply on the `NSManagedObject` subclass the are called on. So `[Car CDK_deleteAllInContext:context]` will delete all `Car` entities in the given context and `[Car CDK_countAllInContext:context]` will count all `Car` entities and subentities in the given context. Other entities are ignored and not touched.

 @param predicateOrNil `NSPredicate` to filter entities on or nil to apply no predicate
 @param contextOrNil   `NSManagedObjectContext` to search through or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`

 @return Number of matching entities
 */
+ (NSUInteger)CDK_countWithPredicate:(NSPredicate *)predicateOrNil
                           inContext:(NSManagedObjectContext *)contextOrNil;

///---------------
/// @name Deleting
///---------------

/**
 Delete all entities in the given context.

 @discussion All of CoreDataKits find, count and delete methods will only find/apply on the `NSManagedObject` subclass the are called on. So `[Car CDK_deleteAllInContext:context]` will delete all `Car` entities in the given context and `[Car CDK_countAllInContext:context]` will count all `Car` entities and subentities in the given context. Other entities are ignored and not touched.

 @param contextOrNil `NSManagedObjectContext` to search through or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`
 */
+ (void)CDK_deleteAllInContext:(NSManagedObjectContext *)contextOrNil;

/**
 Delete entities matching the given `NSPredicate` in the given context.
 
 @discussion All of CoreDataKits find, count and delete methods will only find/apply on the `NSManagedObject` subclass the are called on. So `[Car CDK_deleteAllInContext:context]` will delete all `Car` entities in the given context and `[Car CDK_countAllInContext:context]` will count all `Car` entities and subentities in the given context. Other entities are ignored and not touched.

 @param predicateOrNil `NSPredicate` to filter entities on or nil to apply no predicate
 @param contextOrNil   `NSManagedObjectContext` to search through or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`
 */
+ (void)CDK_deleteWithPredicate:(NSPredicate *)predicateOrNil
                      inContext:(NSManagedObjectContext *)contextOrNil;

/**
 Delete this entity in it's associated context.
 
 @discussion Make sure to first convert the entity to the context you want to delete it from. This method deletes the entity in the `NSManagedObjectContext` it's associated with, not necessarily the context you want to delete it from!
 
 @see -CDK_findInContext:
 */
- (void)CDK_delete;

///---------------------------------
/// @name Fetched Results Controller
///---------------------------------

/**
 Creates a fully initialized `NSFetchedResultsController`.

 @param predicateOrNil          `NSPredicate` to filter entities on or nil to apply no predicate
 @param sortDescriptors         Array of sort descriptors to order the entities by
 @param limitOrZero             Maximum number of entities to fetch or zero to apply no limit
 @param sectionNameKeyPathOrNil A key path on result objects that returns the section name or nil to indicate that the controller should generate a single section
 @param cacheNameOrNil          The name of the cache file the receiver should use or nil to prevent caching
 @param delegateOrNil           Object that is notified when the fetched results changed, when nil the controller does not track changes
 @param contextOrNil            `NSManagedObjectContext` to search through or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`

 @return The initialized `NSFetchedResultsController`
 */
+ (NSFetchedResultsController *)CDK_controllerWithPredicate:(NSPredicate *)predicateOrNil
                                                     sortBy:(NSArray *)sortDescriptors
                                                      limit:(NSUInteger)limitOrZero
                                         sectionNameKeyPath:(NSString *)sectionNameKeyPathOrNil
                                                  cacheName:(NSString *)cacheNameOrNil
                                                   delegate:(id<NSFetchedResultsControllerDelegate>)delegateOrNil
                                                  inContext:(NSManagedObjectContext *)contextOrNil;

/**
 Creates a fully initialized `NSFetchedResultsController`.

 @param fetchRequest            Fetch request to be performed by the returned controller
 @param sectionNameKeyPathOrNil A key path on result objects that returns the section name or nil to indicate that the controller should generate a single section
 @param cacheNameOrNil          The name of the cache file the receiver should use or nil to prevent caching
 @param delegateOrNil           Object that is notified when the fetched results changed, when nil the controller does not track changes
 @param contextOrNil            `NSManagedObjectContext` to search through or nil to use the shared `CoreDataKit`s root `NSManagedObjectContext`

 @return The initialized `NSFetchedResultsController`
 */
+ (NSFetchedResultsController *)CDK_controllerWithFetchRequest:(NSFetchRequest *)fetchRequest
                                            sectionNameKeyPath:(NSString *)sectionNameKeyPathOrNil
                                                     cacheName:(NSString *)cacheNameOrNil
                                                      delegate:(id<NSFetchedResultsControllerDelegate>)delegateOrNil
                                                     inContext:(NSManagedObjectContext *)contextOrNil;

@end
