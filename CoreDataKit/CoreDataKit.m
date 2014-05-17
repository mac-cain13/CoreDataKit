//
//  CoreDataKit.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 15-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import "CoreDataKit.h"
#import "CDKDebugger.h"
#import "NSPersistentStoreCoordinator+CoreDataKit.h"
#import "NSManagedObjectContext+CoreDataKit.h"

static NSString * const kCoreDataKitDefaultStoreName = @"CoreDataKit";

@interface CoreDataKit ()

@property (atomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (atomic, strong) NSManagedObjectContext *rootContext;
@property (atomic, strong) NSManagedObjectContext *mainThreadContext;

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

#pragma mark Setup methods

- (void)setupAutomigratingCoreDataStack
{
    [self setupCoreDataStack:kCoreDataKitDefaultStoreName automigrating:YES];
}

- (void)setupCoreDataStack:(NSString *)storeName automigrating:(BOOL)automigrating
{
    // Validate setup is only runned once
    NSAssert(nil == self.rootContext, @"Root context is already available");
    NSAssert(nil == self.mainThreadContext, @"Main thread context is already available");

    // Prep URL to location + get all models merged together
    NSURL *persistentStoreURL = [NSPersistentStoreCoordinator CDK_URLForStoreName:storeName];
    NSManagedObjectModel *mergedManagedObjectModels = [NSManagedObjectModel mergedModelFromBundles:nil];

    // Setup persistent store
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mergedManagedObjectModels];
    [self.persistentStoreCoordinator CDK_addSQLiteStoreWithURL:persistentStoreURL automigrating:automigrating];

    // Create the contexts
    self.rootContext = [NSManagedObjectContext CDK_contextWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    self.mainThreadContext = [self.rootContext CDK_childContextWithConcurrencyType:NSMainQueueConcurrencyType];
}

- (void)setupCoreDataStackInMemory
{
    // Validate setup is only runned once
    NSAssert(nil == self.rootContext, @"Root context is already available");
    NSAssert(nil == self.mainThreadContext, @"Main thread context is already available");

    // Get all models merged together
    NSManagedObjectModel *mergedManagedObjectModels = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    // Setup persistent store
    NSError *error = nil;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mergedManagedObjectModels];
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];

    CDKHandleError(error);

    // Create the contexts
    self.rootContext = [NSManagedObjectContext CDK_contextWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    self.mainThreadContext = [self.rootContext CDK_childContextWithConcurrencyType:NSMainQueueConcurrencyType];
}

#pragma mark Saving

+ (void)save:(CDKSaveBlock)saveBlock completion:(CDKCompletionBlock)completion
{
    [[self sharedKit] save:saveBlock completion:completion];
}

#warning Untested
- (void)save:(CDKSaveBlock)saveBlock completion:(CDKCompletionBlock)completion
{
    NSManagedObjectContext *managedObjectContext = [self.rootContext CDK_childContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext performBlock:^{
        // Perform save block
        if (saveBlock) {
            saveBlock(managedObjectContext);
        }

        // Save the changes
        [managedObjectContext CDK_saveToPersistentStore:completion];
    }];
}

@end
