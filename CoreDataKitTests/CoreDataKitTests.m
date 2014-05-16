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

#pragma mark Singleton

- (void)testSingletonNotNil
{
    XCTAssertNotNil([CoreDataKit sharedKit], @"sharedKit shouldn't be nil");
}

- (void)testSingletonReturnsSameObject
{
    XCTAssertEqual([CoreDataKit sharedKit], [CoreDataKit sharedKit], @"sharedKit should return same instance twice");
}

#pragma mark StoreName

- (void)testStoreNameNotNil
{
    XCTAssertNotNil(self.coreDataKit.storeName, @"Store name shouldn't be nil by default");
}

- (void)testSetStoreNameToNilResetsToDefault
{
    NSString *defaultStoreName = self.coreDataKit.storeName;
    self.coreDataKit.storeName = nil;
    XCTAssertEqualObjects(self.coreDataKit.storeName, defaultStoreName, @"Setting store name to nil should not change name");
}

@end
