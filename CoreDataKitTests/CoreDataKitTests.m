//
//  CoreDataKitTests.m
//  CoreDataKitTests
//
//  Created by Mathijs Kadijk on 15-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataKit.h"

@interface CoreDataKitTests : XCTestCase

@property (nonatomic, strong) CoreDataKit *coreDataKit;

@end

@implementation CoreDataKitTests

- (void)setUp
{
    [super setUp];
    self.coreDataKit = [[CoreDataKit alloc] init];
}

- (void)tearDown
{
    self.coreDataKit = nil;
    [super tearDown];
}

#pragma mark - Singleton

- (void)testSingletonNotNil
{
    XCTAssertNotNil([CoreDataKit sharedKit], @"sharedKit shouldn't be nil");
}

- (void)testSingletonReturnsSameObject
{
    XCTAssertEqual([CoreDataKit sharedKit], [CoreDataKit sharedKit], @"sharedKit should return same instance twice");
}

#pragma mark - Setup

#pragma mark SQLite setup

- (void)testSetupAutomigratingCoreDataStackTwice
{
    [self.coreDataKit setupAutomigratingCoreDataStack];

    @try {
        [self.coreDataKit setupAutomigratingCoreDataStack];
    }
    @catch (id assertion) {
        XCTAssertEqualObjects([assertion description], @"Root context is already available", @"Setup CoreData stack twice hit wrong assertion");
        return;
    }

    XCTFail(@"Setup CoreData stack twice should hit assertion");
}

- (void)testSetupAutomigratingCoreDataStackCreatesCoordinator
{
    [self.coreDataKit setupAutomigratingCoreDataStack];

    XCTAssertNotNil(self.coreDataKit.persistentStoreCoordinator, @"Persistent store coordinator should be available after setup");
    XCTAssertEqual(self.coreDataKit.persistentStoreCoordinator.persistentStores.count, 1, @"Persistent store coordinator should have one persistent store");
}

- (void)testSetupAutomigratingCoreDataStackCreatesRootContext
{
    [self.coreDataKit setupAutomigratingCoreDataStack];

    XCTAssertNotNil(self.coreDataKit.rootContext, @"Root context should be available after setup");
    XCTAssertEqualObjects(self.coreDataKit.rootContext.persistentStoreCoordinator, self.coreDataKit.persistentStoreCoordinator, @"Root context should associated with the persistent store coordinator");
    XCTAssertNil(self.coreDataKit.rootContext.parentContext, @"Root context must not have a parent context");
}

- (void)testSetupAutomigratingCoreDataStackCreatesMainThreadContext
{
    [self.coreDataKit setupAutomigratingCoreDataStack];

    XCTAssertNotNil(self.coreDataKit.mainThreadContext, @"Main thread context should be available after setup");
    XCTAssertEqualObjects(self.coreDataKit.mainThreadContext.parentContext, self.coreDataKit.rootContext, @"Main thread context should have root context as parent");
    XCTAssertEqualObjects(self.coreDataKit.mainThreadContext.persistentStoreCoordinator, self.coreDataKit.persistentStoreCoordinator, @"Main thread context should have same persistent store coordinator as root context");
}

#pragma mark In memory setup

- (void)testSetupCoreDataStackInMemoryTwice
{
    [self.coreDataKit setupCoreDataStackInMemory];

    @try {
        [self.coreDataKit setupCoreDataStackInMemory];
    }
    @catch (id assertion) {
        XCTAssertEqualObjects([assertion description], @"Root context is already available", @"Setup CoreData stack twice hit wrong assertion");
        return;
    }

    XCTFail(@"Setup CoreData stack twice should hit assertion");
}

- (void)testSetupCoreDataStackInMemoryCreatesCoordinator
{
    [self.coreDataKit setupCoreDataStackInMemory];

    XCTAssertNotNil(self.coreDataKit.persistentStoreCoordinator, @"Persistent store coordinator should be available after setup");
    XCTAssertEqual(self.coreDataKit.persistentStoreCoordinator.persistentStores.count, 1, @"Persistent store coordinator should have one persistent store");
}

- (void)testSetupCoreDataStackInMemoryCreatesRootContext
{
    [self.coreDataKit setupCoreDataStackInMemory];

    XCTAssertNotNil(self.coreDataKit.rootContext, @"Root context should be available after setup");
    XCTAssertEqualObjects(self.coreDataKit.rootContext.persistentStoreCoordinator, self.coreDataKit.persistentStoreCoordinator, @"Root context should associated with the persistent store coordinator");
    XCTAssertNil(self.coreDataKit.rootContext.parentContext, @"Root context must not have a parent context");
}

- (void)testSetupCoreDataStackInMemoryCreatesMainThreadContext
{
    [self.coreDataKit setupCoreDataStackInMemory];

    XCTAssertNotNil(self.coreDataKit.mainThreadContext, @"Main thread context should be available after setup");
    XCTAssertEqualObjects(self.coreDataKit.mainThreadContext.parentContext, self.coreDataKit.rootContext, @"Main thread context should have root context as parent");
    XCTAssertEqualObjects(self.coreDataKit.mainThreadContext.persistentStoreCoordinator, self.coreDataKit.persistentStoreCoordinator, @"Main thread context should have same persistent store coordinator as root context");
}

@end
