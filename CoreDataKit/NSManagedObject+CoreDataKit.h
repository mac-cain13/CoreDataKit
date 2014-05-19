//
//  NSManagedObject+CoreDataKit.h
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 18-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (CoreDataKit)

- (NSArray *)CDK_findWithPredicate:(NSPredicate *)predicate
                            sortBy:(NSArray *)sortDescriptors
                             limit:(NSUInteger)limit
                         inContext:(NSManagedObjectContext *)context;

- (instancetype)CDK_findFirstWithPredicate:(NSPredicate *)predicate
                                    sortBy:(NSArray *)sortDescriptors
                                 inContext:(NSManagedObjectContext *)context;

- (instancetype)CDK_findFirstOrCreateWithPredicate:(NSPredicate *)predicate
                                            sortBy:(NSArray *)sortDescriptors
                                         inContext:(NSManagedObjectContext *)context;

@end
