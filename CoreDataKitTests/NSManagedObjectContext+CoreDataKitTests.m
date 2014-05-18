//
//  NSManagedObjectContext+CoreDataKitTests.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <XCTest/XCTest.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#import "NSManagedObjectContext+CoreDataKit.h"

@interface NSManagedObjectContext_CoreDataKitTests : XCTestCase

@end

@implementation NSManagedObjectContext_CoreDataKitTests

#pragma mark Context creation

- (void)testContextWithMissingPersistentStoreCoordinator
{
    @try {
        [NSManagedObjectContext CDK_contextWithPersistentStoreCoordinator:nil];
    }
    @catch (id assertion) {
        XCTAssertEqualObjects([assertion description], @"Persistent store coordinator is mandatory", @"Context without persistent store coordinator hit wrong assertion");
        return;
    }

    XCTFail(@"Context without persistent store coordinator should hit assertion");
}

- (void)testContextWithPersistentStoreCoordinator
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = mock([NSPersistentStoreCoordinator class]);
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext CDK_contextWithPersistentStoreCoordinator:persistentStoreCoordinator];

    XCTAssertNotNil(managedObjectContext, @"Created managed object context shouldn't be nil");
    XCTAssertEqualObjects(managedObjectContext.persistentStoreCoordinator, persistentStoreCoordinator, @"Managed object context should have given persisten store coordinator");
    XCTAssertNil(managedObjectContext.parentContext, @"Managed object context shouldn't have a parent context");
}

- (void)testChildContextWithConcurrencyType
{
    NSManagedObjectContext *parentManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSManagedObjectContext *childManagedObjectContext = [parentManagedObjectContext CDK_childContextWithConcurrencyType:NSPrivateQueueConcurrencyType];

    XCTAssertNotNil(childManagedObjectContext, @"Created child managed object context shouldn't be nil");
    XCTAssertEqualObjects(childManagedObjectContext.parentContext, parentManagedObjectContext, @"Child managed object context should have called class as parent");
}

#pragma mark Saving

- (void)testSaveToPersistentStoreCallsParentSave
{
    NSManagedObjectContext *parentManagedObjectContext = mock([NSManagedObjectContext class]);
    [given([parentManagedObjectContext concurrencyType]) willReturnUnsignedInteger:NSPrivateQueueConcurrencyType];

    NSManagedObjectContext *childManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    childManagedObjectContext.parentContext = parentManagedObjectContext;

    CDKCompletionBlock completion = ^(NSError *error) {};
    [childManagedObjectContext CDK_saveToPersistentStore:completion];

#warning Should wait for async action to call this
    [verifyCount(parentManagedObjectContext, times(1)) CDK_saveToPersistentStore:completion];
}

- (void)testSaveToPersistentStoreWithoutParentCallsCompletion
{
    NSManagedObjectContext *childManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    [childManagedObjectContext CDK_saveToPersistentStore:^(NSError *error) {
        XCTAssertNil(error, @"Should call save block with nil");
    }];

#warning Should wait for completion block to be called
}

- (void)testSaveToPersistentStoreCallsSave
{
    XCTFail(@"Unimplemented test");
}

#warning Should test: create object, save, retrieve
#warning Should test: create invalid object, save, calls completion with error

@end
