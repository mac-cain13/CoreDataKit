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

@end
