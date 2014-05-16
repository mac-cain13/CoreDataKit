//
//  NSPersistentStoreCoordinator+CoreDataKitTests.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSPersistentStoreCoordinator+CoreDataKit.h"

@interface NSPersistentStoreCoordinator_CoreDataKitTests : XCTestCase

@end

@implementation NSPersistentStoreCoordinator_CoreDataKitTests

- (void)testURLForStoreNameWithNil
{
    @try {
        [NSPersistentStoreCoordinator CDK_URLForStoreName:nil];
    }
    @catch (id assertion) {
        XCTAssertEqualObjects([assertion description], @"Store name is mandatory", @"URL creation hit wrong assert");
        return;
    }

    XCTFail(@"URL creation with nil store name should hit assertion");
}

- (void)testURLForStoreNameWithEmptyString
{
    @try {
        [NSPersistentStoreCoordinator CDK_URLForStoreName:@""];
    }
    @catch (id assertion) {
        XCTAssertEqualObjects([assertion description], @"Store name is mandatory", @"URL creation hit wrong assert");
        return;
    }

    XCTFail(@"URL creation with nil store name should hit assertion");
}

@end
