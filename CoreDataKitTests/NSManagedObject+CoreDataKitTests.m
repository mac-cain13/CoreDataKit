//
//  NSManagedObject+CoreDataKitTests.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 19-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <XCTestAsync.h>
#import "CDKTestCase.h"
#import "CoreDataKit.h"
#import "NSManagedObject+CoreDataKit.h"
#import "NSManagedObjectContext+CoreDataKit.h"
#import "Car.h"

@interface NSManagedObject_CoreDataKitTests : CDKTestCase

@end

@implementation NSManagedObject_CoreDataKitTests

- (void)testNoManagedObjectsAtStart
{
    NSArray *resultsBeforeInsert = [Car CDK_findAllSortedBy:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]
                                                  inContext:self.coreDataKit.rootContext];
    XCTAssertNotNil(resultsBeforeInsert, @"Result array should be returned");
    XCTAssertEqual(resultsBeforeInsert.count, 0, @"There should be no results");
}

#pragma mark -

#pragma mark EntityDescriptionInContext
- (void)testEntityDescriptionInContextWithNil
{
    NSEntityDescription *carDescription = [Car CDK_entityDescriptionInContext:nil];

    XCTAssertNotNil(carDescription, @"NSEntityDescription should not be nil");
    XCTAssertEqualObjects(carDescription.managedObjectClassName, NSStringFromClass([Car class]), @"NSEntityDescription should be for managedObjectClassName Car");
    XCTAssertEqualObjects(carDescription.name, @"Car", @"NSEntityDescription should be for entity Car");
}

- (void)testEntityDescriptionInContextWithGivenContext
{
    NSEntityDescription *carDescription = [Car CDK_entityDescriptionInContext:self.coreDataKit.rootContext];

    XCTAssertNotNil(carDescription, @"NSEntityDescription should not be nil");
    XCTAssertEqualObjects(carDescription.managedObjectClassName, NSStringFromClass([Car class]), @"NSEntityDescription should be for managedObjectClassName Car");
    XCTAssertEqualObjects(carDescription.name, @"Car", @"NSEntityDescription should be for entity Car");
}

#pragma mark CreateInContext
- (void)testCreateInContextWithNil
{
    Car *returnedCar = [Car CDK_createInContext:nil];
    XCTAssertNotNil(returnedCar, @"A Car instance should be returned");

    NSManagedObject *fetchedCar = [[CoreDataKit sharedKit].rootContext objectWithID:returnedCar.objectID];
    XCTAssertEqual(returnedCar, fetchedCar, @"Created car should be available in shared context");
}

- (void)testCreateInContextWithGivenContext
{
    Car *returnedCar = [Car CDK_createInContext:self.coreDataKit.mainThreadContext];
    XCTAssertNotNil(returnedCar, @"A Car instance should be returned");

    NSManagedObject *fetchedCar = [self.coreDataKit.mainThreadContext objectWithID:returnedCar.objectID];
    XCTAssertEqual(returnedCar, fetchedCar, @"Created car should be available in the given context");
}

#pragma mark -

#pragma mark RequestInContext

- (void)testRequest
{
    NSFetchRequest *request = [Car CDK_requestInContext:nil];
    XCTAssertNotNil(request, @"Fetch request should not be nil");
    XCTAssertEqualObjects(request.entity.name, @"Car", @"Fetch request should be for Car");
}

#pragma mark FindInContext

- (void)testFindInContextWithNil
{
    @try {
        Car *car = [Car CDK_createInContext:nil];
        [car CDK_findInContext:nil];
    }
    @catch (id assertion) {
        XCTAssertEqualObjects([assertion description], @"Managed object context cannot be nil", @"Find in context should assert when context is nil");
        return;
    }
}

- (void)testFindInContextAsync
{
    NSManagedObjectContext *context = [self.coreDataKit.rootContext CDK_childContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
    Car *car = [Car CDK_createInContext:context];

    Car *fetchedCarBeforeSave = [car CDK_findInContext:context.parentContext];
    XCTAssertNil(fetchedCarBeforeSave, @"Fetched car should not yet be available in parent context");

    [context CDK_saveToParentContext:^(NSError *error) {
        XCTAssertNil(error, @"Error during save to other context");

        Car *fetchedCarAfterSave = [car CDK_findInContext:context.parentContext];
        XCTAssertNotNil(fetchedCarAfterSave, @"Car not found in root context after save");
        XCTAssertEqualObjects(fetchedCarAfterSave.objectID, car.objectID, @"Fetched car is not similar");

        XCAsyncSuccess();
    }];

    XCAsyncFailAfter(1, @"Timed out");
}

#pragma mark FindAllSortedByInContext

- (void)testFindAllSortedByInContext
{
    [self seedWithCars:@[@"a", @"b", @"c"] inContext:self.coreDataKit.rootContext];

    NSArray *resultsAfterInsert = [Car CDK_findAllSortedBy:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]
                                                 inContext:self.coreDataKit.rootContext];
    XCTAssertNotNil(resultsAfterInsert, @"Result array should be returned");
    XCTAssertEqual(resultsAfterInsert.count, 3, @"There should be 3 results");
}

- (void)testFindAllSortedByInContextUsingSorting
{
    NSArray *names = @[@"a", @"b", @"c"];
    [self seedWithCars:names inContext:self.coreDataKit.rootContext];

    NSArray *resultsAfterInsert = [Car CDK_findAllSortedBy:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]
                                               inContext:self.coreDataKit.rootContext];
    XCTAssertNotNil(resultsAfterInsert, @"Result array should be returned");
    XCTAssertEqual(resultsAfterInsert.count, 3, @"There should be 3 results");

    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        Car *car = (Car *)resultsAfterInsert[resultsAfterInsert.count - (1 + idx)];
        XCTAssertEqualObjects(car.name, name, @"Order of cars is incorrect");
    }];
}

#pragma mark FindWithPredicateSortByLimitInContext

- (void)testFindWithPredicateSortByLimitInContextAllParameters
{
    [self seedWithCars:@[@"a", @"b", @"c", @"d"] inContext:self.coreDataKit.rootContext];

    NSArray *resultsAfterInsert = [Car CDK_findWithPredicate:[NSPredicate predicateWithFormat:@"name = 'b' OR name = 'd'"]
                                                      sortBy:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]
                                                       limit:1
                                                   inContext:self.coreDataKit.rootContext];
    XCTAssertNotNil(resultsAfterInsert, @"Result array should be returned");
    XCTAssertEqual(resultsAfterInsert.count, 1, @"There should be 1 results");
    XCTAssertEqualObjects([(Car *)resultsAfterInsert.firstObject name], @"d", @"Should have found Car with highest name");
}

- (void)testFindWithPredicateSortByLimitInContextNoLimit
{
    [self seedWithCars:@[@"a", @"b", @"c", @"d"] inContext:self.coreDataKit.rootContext];

    NSArray *resultsAfterInsert = [Car CDK_findWithPredicate:[NSPredicate predicateWithFormat:@"name = 'b' OR name = 'd'"]
                                                      sortBy:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]
                                                       limit:0
                                                   inContext:self.coreDataKit.rootContext];
    XCTAssertNotNil(resultsAfterInsert, @"Result array should be returned");
    XCTAssertEqual(resultsAfterInsert.count, 2, @"There should be 2 results");
    XCTAssertEqualObjects([(Car *)resultsAfterInsert.firstObject name], @"d", @"Should have found Car d first");
    XCTAssertEqualObjects([(Car *)resultsAfterInsert[1] name], @"b", @"Should have found Car b second");
}

#pragma mark - Helper method
- (void)seedWithCars:(NSArray *)names inContext:(NSManagedObjectContext *)context
{
    // Save some objects into CoreData
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        Car *car = [Car CDK_createInContext:context];
        car.name = name;
    }];
}

@end
