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
#import <XCTestAsync/XCTestAsync.h>
#import "NSManagedObjectContext+CoreDataKit.h"

#pragma mark - Testing subclasses

@interface TestingNSManagedObjectContext : NSManagedObjectContext

@property (nonatomic, assign) int saveToPersistentStoreCalled;
@property (nonatomic, assign) int saveCalled;

@end

@implementation TestingNSManagedObjectContext

- (void)CDK_saveToPersistentStore:(CDKCompletionBlock)completion
{
    self.saveToPersistentStoreCalled++;
    [super CDK_saveToPersistentStore:completion];
}

- (BOOL)save:(NSError *__autoreleasing *)error
{
    self.saveCalled++;
    return [super save:error];
}

@end

#pragma mark - Test class

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

- (void)testChildContextWithConcurrencyTypeInvalid
{
    @try {
        NSManagedObjectContext *parentManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [parentManagedObjectContext CDK_childContextWithConcurrencyType:NSConfinementConcurrencyType];
    }
    @catch (id assertion) {
        XCTAssertEqualObjects([assertion description], @"NSConfinementConcurrencyType shouldn't be used as concurrency type", @"Child context with NSConfinementConcurrencyType should be refused");
        return;
    }

    XCTFail(@"Child context with NSConfinementConcurrencyType should hit assertion");
}

#pragma mark SaveToPersistentStore

- (void)testSaveToPersistentStoreCallsParentSaveAsync
{
    TestingNSManagedObjectContext *parentManagedObjectContext = [[TestingNSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    NSManagedObjectContext *childManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    childManagedObjectContext.parentContext = parentManagedObjectContext;

    [childManagedObjectContext CDK_saveToPersistentStore:^(NSError *error) {
        XCTAssertEqual(parentManagedObjectContext.saveToPersistentStoreCalled, 1, @"Should call parent save to persistent store once.");
        XCAsyncSuccess();
    }];

    XCAsyncFailAfter(1, @"Should have called completion block");
}

- (void)testSaveToPersistentStoreWithoutParentCallsCompletionAsync
{
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    [managedObjectContext CDK_saveToPersistentStore:^(NSError *error) {
        XCTAssertNil(error, @"Should call save block with nil error");
        XCAsyncSuccess();
    }];

    XCAsyncFailAfter(1, @"Should have called completion block");
}

- (void)testSaveToPersistentStoreCallsSaveAsync
{
    TestingNSManagedObjectContext *managedObjectContext = [[TestingNSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    [managedObjectContext CDK_saveToPersistentStore:^(NSError *error) {
        XCTAssertEqual(managedObjectContext.saveCalled, 1, @"Should call save once.");
        XCAsyncSuccess();
    }];

    XCAsyncFailAfter(1, @"Should have called completion block");
}

#warning Should test: create object, save, retrieve
#warning Should test: create invalid object, save, calls completion with error

#pragma mark SaveToParentContext

- (void)testSaveToParentContextAsync
{
    TestingNSManagedObjectContext *managedObjectContext = [[TestingNSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    [managedObjectContext CDK_saveToParentContext:^(NSError *error) {
        XCTAssertEqual(managedObjectContext.saveCalled, 1, @"Should call save once.");
        XCAsyncSuccess();
    }];

    XCAsyncFailAfter(1, @"Should have called completion block");
}

#warning Should test: create object, save, retrieve
#warning Should test: create invalid object, save, calls completion with error

@end
