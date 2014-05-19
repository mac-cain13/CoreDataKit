//
//  CoreDataKitTests.m
//  CoreDataKitTests
//
//  Created by Mathijs Kadijk on 15-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDKTestCase.h"
#import "CoreDataKit.h"
#import "Car.h"

@interface CoreDataKitTests : CDKTestCase

@property (nonatomic, strong) CoreDataKit *cleanCoreDataKit;

@end

@implementation CoreDataKitTests

- (void)setUp
{
    [super setUp];

    self.cleanCoreDataKit = [[CoreDataKit alloc] init];
}

- (void)tearDown
{
    self.cleanCoreDataKit = nil;

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
    [self.cleanCoreDataKit setupAutomigratingCoreDataStack];

    @try {
        [self.cleanCoreDataKit setupAutomigratingCoreDataStack];
    }
    @catch (id assertion) {
        XCTAssertEqualObjects([assertion description], @"Root context is already available", @"Setup CoreData stack twice hit wrong assertion");
        return;
    }

    XCTFail(@"Setup CoreData stack twice should hit assertion");
}

- (void)testSetupAutomigratingCoreDataStackCreatesCoordinator
{
    [self.cleanCoreDataKit setupAutomigratingCoreDataStack];

    XCTAssertNotNil(self.cleanCoreDataKit.persistentStoreCoordinator, @"Persistent store coordinator should be available after setup");
    XCTAssertEqual(self.cleanCoreDataKit.persistentStoreCoordinator.persistentStores.count, 1, @"Persistent store coordinator should have one persistent store");
}

- (void)testSetupAutomigratingCoreDataStackCreatesRootContext
{
    [self.cleanCoreDataKit setupAutomigratingCoreDataStack];

    XCTAssertNotNil(self.cleanCoreDataKit.rootContext, @"Root context should be available after setup");
    XCTAssertEqualObjects(self.cleanCoreDataKit.rootContext.persistentStoreCoordinator, self.cleanCoreDataKit.persistentStoreCoordinator, @"Root context should associated with the persistent store coordinator");
    XCTAssertNil(self.cleanCoreDataKit.rootContext.parentContext, @"Root context must not have a parent context");
}

- (void)testSetupAutomigratingCoreDataStackCreatesMainThreadContext
{
    [self.cleanCoreDataKit setupAutomigratingCoreDataStack];

    XCTAssertNotNil(self.cleanCoreDataKit.mainThreadContext, @"Main thread context should be available after setup");
    XCTAssertEqualObjects(self.cleanCoreDataKit.mainThreadContext.parentContext, self.cleanCoreDataKit.rootContext, @"Main thread context should have root context as parent");
    XCTAssertEqualObjects(self.cleanCoreDataKit.mainThreadContext.persistentStoreCoordinator, self.cleanCoreDataKit.persistentStoreCoordinator, @"Main thread context should have same persistent store coordinator as root context");
}

#pragma mark In memory setup

- (void)testSetupCoreDataStackInMemoryTwice
{
    [self.cleanCoreDataKit setupCoreDataStackInMemory];

    @try {
        [self.cleanCoreDataKit setupCoreDataStackInMemory];
    }
    @catch (id assertion) {
        XCTAssertEqualObjects([assertion description], @"Root context is already available", @"Setup CoreData stack twice hit wrong assertion");
        return;
    }

    XCTFail(@"Setup CoreData stack twice should hit assertion");
}

- (void)testSetupCoreDataStackInMemoryCreatesCoordinator
{
    [self.cleanCoreDataKit setupCoreDataStackInMemory];

    XCTAssertNotNil(self.cleanCoreDataKit.persistentStoreCoordinator, @"Persistent store coordinator should be available after setup");
    XCTAssertEqual(self.cleanCoreDataKit.persistentStoreCoordinator.persistentStores.count, 1, @"Persistent store coordinator should have one persistent store");
}

- (void)testSetupCoreDataStackInMemoryCreatesRootContext
{
    [self.cleanCoreDataKit setupCoreDataStackInMemory];

    XCTAssertNotNil(self.cleanCoreDataKit.rootContext, @"Root context should be available after setup");
    XCTAssertEqualObjects(self.cleanCoreDataKit.rootContext.persistentStoreCoordinator, self.cleanCoreDataKit.persistentStoreCoordinator, @"Root context should associated with the persistent store coordinator");
    XCTAssertNil(self.cleanCoreDataKit.rootContext.parentContext, @"Root context must not have a parent context");
}

- (void)testSetupCoreDataStackInMemoryCreatesMainThreadContext
{
    [self.cleanCoreDataKit setupCoreDataStackInMemory];

    XCTAssertNotNil(self.cleanCoreDataKit.mainThreadContext, @"Main thread context should be available after setup");
    XCTAssertEqualObjects(self.cleanCoreDataKit.mainThreadContext.parentContext, self.cleanCoreDataKit.rootContext, @"Main thread context should have root context as parent");
    XCTAssertEqualObjects(self.cleanCoreDataKit.mainThreadContext.persistentStoreCoordinator, self.cleanCoreDataKit.persistentStoreCoordinator, @"Main thread context should have same persistent store coordinator as root context");
}

#pragma mark - Saving

- (void)testSaveAndRetrieveAsync
{
    NSString *name = [[NSUUID UUID] UUIDString];
    [self.coreDataKit save:^(NSManagedObjectContext *context) {
        Car *car = [[Car alloc] initWithEntity:[NSEntityDescription entityForName:@"Car" inManagedObjectContext:self.coreDataKit.rootContext]
                insertIntoManagedObjectContext:self.coreDataKit.rootContext];
        car.name = name;
    } completion:^(NSError *error) {
        XCTAssertNil(error, @"Saving should not generate error");

        // Core Data fetch snipped
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Car" inManagedObjectContext:self.coreDataKit.rootContext];
        [fetchRequest setEntity:entity];

        NSArray *fetchedObjects = [self.coreDataKit.rootContext executeFetchRequest:fetchRequest error:NULL];
        XCTAssertEqualObjects(((Car *)fetchedObjects.firstObject).name, name, @"Car with name should be retrieved");

        XCAsyncSuccess();
    }];

    XCAsyncFailAfter(1, @"Saving timed out");
}

@end
