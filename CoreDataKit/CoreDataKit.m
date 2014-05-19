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

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *rootContext;
@property (nonatomic, strong) NSManagedObjectContext *mainThreadContext;

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
    [self setupCoreDataStack:kCoreDataKitDefaultStoreName
               automigrating:YES
          managedObjectModel:nil];
}

- (void)setupCoreDataStack:(NSString *)storeName
             automigrating:(BOOL)automigrating
        managedObjectModel:(NSManagedObjectModel *)managedObjectModelOrNil
{
    // Validate setup is only runned once
    NSAssert(nil == _rootContext, @"Root context is already available");
    NSAssert(nil == _mainThreadContext, @"Main thread context is already available");

    // Prep URL to location + get all models merged together
    NSURL *persistentStoreURL = [NSPersistentStoreCoordinator CDK_URLForStoreName:storeName];
    NSManagedObjectModel *mergedManagedObjectModel = (managedObjectModelOrNil) ?: [NSManagedObjectModel mergedModelFromBundles:nil];

    // Setup persistent store
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mergedManagedObjectModel];
    [self.persistentStoreCoordinator CDK_addSQLiteStoreWithURL:persistentStoreURL automigrating:automigrating];

    // Create the contexts
    self.rootContext = [NSManagedObjectContext CDK_contextWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    self.mainThreadContext = [self.rootContext CDK_childContextWithConcurrencyType:NSMainQueueConcurrencyType];
}

- (void)setupCoreDataStackInMemory
{
    [self setupCoreDataStackInMemoryWithManagedObjectModel:nil];
}

- (void)setupCoreDataStackInMemoryWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModelOrNil
{
    // Validate setup is only runned once
    NSAssert(nil == _rootContext, @"Root context is already available");
    NSAssert(nil == _mainThreadContext, @"Main thread context is already available");

    // Get all models merged together
    NSManagedObjectModel *mergedManagedObjectModel = (managedObjectModelOrNil) ?: [NSManagedObjectModel mergedModelFromBundles:nil];
    
    // Setup persistent store
    NSError *error = nil;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mergedManagedObjectModel];
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

#pragma mark Accessors
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        CDKLogWarn(@"Persistent store coordinator on %@ is not set, did you forgot to call setup?", self);
    }

    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)rootContext
{
    if (!_rootContext) {
        CDKLogWarn(@"Root context on %@ is not set, did you forgot to call setup?", self);
    }

    return _rootContext;
}

- (NSManagedObjectContext *)mainThreadContext
{
    if (!_mainThreadContext) {
        CDKLogWarn(@"Main thread context on %@ is not set, did you forgot to call setup?", self);
    }

    return _mainThreadContext;
}

@end
