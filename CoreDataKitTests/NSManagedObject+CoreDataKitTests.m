//
//  NSManagedObject+CoreDataKitTests.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 19-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDKTestCase.h"
#import "CoreDataKit.h"
#import "NSManagedObject+CoreDataKit.h"
#import "Car.h"

@interface NSManagedObject_CoreDataKitTests : CDKTestCase

@end

@implementation NSManagedObject_CoreDataKitTests

- (void)testEntityDescriptionInContextWithNil
{
    [[CoreDataKit sharedKit] setupCoreDataStackInMemoryWithManagedObjectModel:self.coreDataKit.persistentStoreCoordinator.managedObjectModel];
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

@end
