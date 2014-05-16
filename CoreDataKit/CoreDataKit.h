//
//  CoreDataKit.h
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 15-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

#import "Types.h"

@interface CoreDataKit : NSObject

@property (nonatomic, copy) NSString *storeName;

+ (instancetype)sharedKit;

- (void)setupCoreDataStack;

- (void)setupAutomigratingCoreDataStack;

- (void)setupCoreDataStackInMemory;

#pragma mark Saving

+ (void)save:(CDKSaveBlock)saveBlock completion:(CDKCompletionBlock)completion;

- (void)save:(CDKSaveBlock)saveBlock completion:(CDKCompletionBlock)completion;

@end
