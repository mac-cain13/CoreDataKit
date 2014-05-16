//
//  CoreDataKit.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 15-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import "CoreDataKit.h"

static NSString * const kCoreDataKitDefaultStoreName = @"CoreDataKitStore";

@interface CoreDataKit ()

@end

@implementation CoreDataKit

+ (instancetype)sharedKit
{
    static CoreDataKit *sharedKit;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedKit = [[CoreDataKit alloc] init];
    });

    return sharedKit;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.storeName = kCoreDataKitDefaultStoreName;

    return self;
}

#pragma mark Setup methods

- (void)setupCoreDataStack
{
#warning Unimplemented method
}

- (void)setupAutomigratingCoreDataStack
{
#warning Unimplemented method
}

- (void)setupCoreDataStackInMemory
{
#warning Unimplemented method
}

@end
