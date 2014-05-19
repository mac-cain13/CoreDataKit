//
//  NSManagedObjectContext+CoreDataKitTests.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDKTestCase.h"

#import "CoreDataKit.h"
#import "NSManagedObjectContext+CoreDataKit.h"
#import "Car.h"

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

@interface NSManagedObjectContext_CoreDataKitTests : CDKTestCase

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

#pragma mark ObtainPermanentIDsForInsertedObjects

- (void)testObtainPermanentIDsForInsertedObjects
{
    Car *car = [[Car alloc] initWithEntity:[NSEntityDescription entityForName:@"Car" inManagedObjectContext:self.coreDataKit.rootContext]
            insertIntoManagedObjectContext:self.coreDataKit.rootContext];

    XCTAssertEqual(car.objectID.isTemporaryID, YES, @"Created object should have temporary ID");

    [self.coreDataKit.rootContext CDK_obtainPermanentIDsForInsertedObjects];

    XCTAssertEqual(car.objectID.isTemporaryID, NO, @"Created object should have obtained permanent ID");
}

@end
