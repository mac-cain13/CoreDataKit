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

#pragma mark - Helper method
- (void)seedWithCars:(NSArray *)names inContext:(NSManagedObjectContext *)context
{
    // Save some objects into CoreData
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        Car *car = [Car CDK_createInContext:context];
        car.name = name;
    }];
}

#pragma mark - General tests

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

    [context CDK_performBlockAndSaveToPersistentStore:nil completion:^(NSError *error) {
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

- (void)testFindWithPredicateSortByLimitInContextObjectShouldBeFault
{
    NSManagedObjectContext *saveContext = [self.coreDataKit.rootContext CDK_childContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self seedWithCars:@[@"a", @"b", @"c", @"d"] inContext:saveContext];
    [saveContext save:nil];

    NSManagedObjectContext *fetchContext = [self.coreDataKit.rootContext CDK_childContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSArray *resultsAfterInsert = [Car CDK_findWithPredicate:[NSPredicate predicateWithFormat:@"name = 'b' OR name = 'd'"]
                                                      sortBy:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]
                                                       limit:1
                                                   inContext:fetchContext];
    Car *fetchedCar = resultsAfterInsert.firstObject;
    XCTAssertTrue(fetchedCar.isFault, @"Object should be fault");
}

#pragma mark FindFirstWithPredicateSortByInContext

- (void)testFindFirstWithPredicateSortByInContextUsingSort
{
    [self seedWithCars:@[@"a", @"b", @"c"] inContext:self.coreDataKit.rootContext];

    Car *car = [Car CDK_findFirstWithPredicate:nil
                                        sortBy:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]
                                     inContext:self.coreDataKit.rootContext];
    XCTAssertEqualObjects(car.name, @"c", @"Didn't find correct Car");
}

- (void)testFindFirstWithPredicateSortByInContextUsingSortAndPredicate
{
    [self seedWithCars:@[@"a", @"b", @"c"] inContext:self.coreDataKit.rootContext];

    Car *car = [Car CDK_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name = 'b'"]
                                        sortBy:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]
                                     inContext:self.coreDataKit.rootContext];
    XCTAssertEqualObjects(car.name, @"b", @"Didn't find correct Car");
}

#pragma mark FindFirstOrCreateWithPredicateSortByInContext

- (void)testFindFirstOrCreateWithPredicateSortByInContextNotAvailable
{
    [self seedWithCars:@[@"a", @"b", @"c"] inContext:self.coreDataKit.rootContext];

    Car *car = [Car CDK_findFirstOrCreateWithPredicate:[NSPredicate predicateWithFormat:@"name = 'd'"]
                                                sortBy:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]
                                             inContext:self.coreDataKit.rootContext];
    XCTAssertNotNil(car, @"An object should be returned");
    XCTAssertNil(car.name, @"Object should be empty");
}

- (void)testFindFirstWithPredicateSortByInContextObjectAvailable
{
    [self seedWithCars:@[@"a", @"b", @"c", @"d"] inContext:self.coreDataKit.rootContext];

    Car *car = [Car CDK_findFirstOrCreateWithPredicate:[NSPredicate predicateWithFormat:@"name = 'd'"]
                                                sortBy:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]
                                             inContext:self.coreDataKit.rootContext];
    XCTAssertNotNil(car, @"An object should be returned");
    XCTAssertEqualObjects(car.name, @"d", @"Object should not be empty");
}

#pragma mark -

#pragma mark CountAllInContext

- (void)testCountAllInContextEmpty
{
    NSUInteger count = [Car CDK_countAllInContext:self.coreDataKit.rootContext];
    XCTAssertEqual(count, 0, @"Should not find object");
}

- (void)testCountAllInContextFilled
{
    [self seedWithCars:@[@"a", @"b", @"c", @"d"] inContext:self.coreDataKit.rootContext];

    NSUInteger count = [Car CDK_countAllInContext:self.coreDataKit.rootContext];
    XCTAssertEqual(count, 4, @"Should count 4 objects");
}

#pragma mark CountWithPredicateInContext

- (void)testCountWithPredicateInContextEmpty
{
    NSUInteger count = [Car CDK_countWithPredicate:[NSPredicate predicateWithFormat:@"name = 'd'"]
                                         inContext:self.coreDataKit.rootContext];
    XCTAssertEqual(count, 0, @"Should not find object");
}

- (void)testCountWithPredicateInContextFilled
{
    [self seedWithCars:@[@"a", @"b", @"c", @"d"] inContext:self.coreDataKit.rootContext];

    NSUInteger count = [Car CDK_countWithPredicate:[NSPredicate predicateWithFormat:@"name = 'd'"]
                                         inContext:self.coreDataKit.rootContext];
    XCTAssertEqual(count, 1, @"Should count 1 object");
}

#pragma mark -

#pragma mark DeleteAllInContext

- (void)testDeleteAllInContext
{
    [self seedWithCars:@[@"a", @"b", @"c", @"d"] inContext:self.coreDataKit.rootContext];

    [Car CDK_deleteAllInContext:self.coreDataKit.rootContext];

    NSUInteger count = [Car CDK_countAllInContext:self.coreDataKit.rootContext];
    XCTAssertEqual(count, 0, @"All objects should be deleted");
}

#pragma mark DeleteWithPredicateInContext

- (void)testDeleteWithPredicateInContext
{
    [self seedWithCars:@[@"a", @"b", @"c", @"d"] inContext:self.coreDataKit.rootContext];

    [Car CDK_deleteWithPredicate:[NSPredicate predicateWithFormat:@"name = 'd'"]
                       inContext:self.coreDataKit.rootContext];

    NSUInteger count = [Car CDK_countAllInContext:self.coreDataKit.rootContext];
    XCTAssertEqual(count, 3, @"One object should be deleted");
}

- (void)testDeleteWithPredicateInContextNilPredicate
{
    [self seedWithCars:@[@"a", @"b", @"c", @"d"] inContext:self.coreDataKit.rootContext];

    [Car CDK_deleteWithPredicate:nil inContext:self.coreDataKit.rootContext];

    NSUInteger count = [Car CDK_countAllInContext:self.coreDataKit.rootContext];
    XCTAssertEqual(count, 0, @"All objects should be deleted");
}

#pragma mark Delete

- (void)testDelete
{
    [self seedWithCars:@[@"d"] inContext:self.coreDataKit.rootContext];
    Car *car = [Car CDK_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name = 'd'"] sortBy:nil inContext:self.coreDataKit.rootContext];
    XCTAssertNotNil(car, @"Car should not be nil");

    [car CDK_delete];

    NSUInteger count = [Car CDK_countAllInContext:self.coreDataKit.rootContext];
    XCTAssertEqual(count, 0, @"Objects should be deleted");
}

#pragma mark -

#pragma mark ControllerWithFetchRequestSectionNameKeyPathCacheNameDelegateInContext

- (void)testControllerWithPredicateSortByLimitSectionNameKeyPathCacheNameDelegateInContext
{
    NSPredicate *predicate = mock([NSPredicate class]);
    NSArray *sortDescriptor = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    id delegate = mockProtocol(@protocol(NSFetchedResultsControllerDelegate));

    NSFetchedResultsController *frc = [Car CDK_controllerWithPredicate:predicate
                                                                sortBy:sortDescriptor
                                                                 limit:5
                                                    sectionNameKeyPath:@"name"
                                                             cacheName:@"cacheName"
                                                              delegate:delegate
                                                             inContext:self.coreDataKit.rootContext];

    XCTAssertNotNil(frc, @"FRC should not be nil");
    XCTAssertEqualObjects(frc.fetchRequest.predicate, predicate, @"FRC predicate should be given predicate");
    XCTAssertEqualObjects(frc.fetchRequest.sortDescriptors, sortDescriptor, @"FRC sort descriptor should be given sort descriptor");
    XCTAssertEqual(frc.fetchRequest.fetchLimit, 5, @"FRC limit should be given fetch limit");

    XCTAssertEqualObjects(frc.sectionNameKeyPath, @"name", @"FRC section keypath should be given keypath");
    XCTAssertEqualObjects(frc.cacheName, @"cacheName", @"FRC cacheName should be given cacheName");
    XCTAssertEqualObjects(frc.delegate, delegate, @"FRC delegate should be given delegate");
    XCTAssertEqualObjects(frc.managedObjectContext, self.coreDataKit.rootContext, @"FRC context should be given context");
}

#pragma mark ControllerWithFetchRequestSectionNameKeyPathCacheNameDelegateInContext

- (void)testControllerWithFetchRequestSectionNameKeyPathCacheNameDelegateInContext
{
    NSFetchRequest *fetchRequest = mock([NSFetchRequest class]);
    [given([fetchRequest sortDescriptors]) willReturn:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]];
    id delegate = mockProtocol(@protocol(NSFetchedResultsControllerDelegate));

    NSFetchedResultsController *frc = [Car CDK_controllerWithFetchRequest:fetchRequest
                                                       sectionNameKeyPath:@"name"
                                                                cacheName:@"cacheName"
                                                                 delegate:delegate
                                                                inContext:self.coreDataKit.rootContext];

    XCTAssertNotNil(frc, @"FRC should not be nil");
    XCTAssertEqualObjects(frc.fetchRequest, fetchRequest, @"FRC fetch request should be given request");
    XCTAssertEqualObjects(frc.sectionNameKeyPath, @"name", @"FRC section keypath should be given keypath");
    XCTAssertEqualObjects(frc.cacheName, @"cacheName", @"FRC cacheName should be given cacheName");
    XCTAssertEqualObjects(frc.delegate, delegate, @"FRC delegate should be given delegate");
    XCTAssertEqualObjects(frc.managedObjectContext, self.coreDataKit.rootContext, @"FRC context should be given context");
}


@end
