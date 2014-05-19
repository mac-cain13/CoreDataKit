//
//  CDKTestCase.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 19-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CDKTestCase.h"
#import "CoreDataKit.h"

@implementation CDKTestCase

- (void)setUp
{
    [super setUp];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:@[bundle]];

    self.coreDataKit = [[CoreDataKit alloc] init];
    [self.coreDataKit setupCoreDataStackInMemoryWithManagedObjectModel:managedObjectModel];
}

- (void)tearDown
{
    self.coreDataKit = nil;

    [super tearDown];
}

@end
