//
//  NSPersistentStoreCoordinator+CoreDataKit.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import "NSPersistentStoreCoordinator+CoreDataKit.h"
#import "CDKDebugger.h"

@implementation NSPersistentStoreCoordinator (CoreDataKit)

+ (NSURL *)CDK_URLForStoreName:(NSString *)storeName
{
    NSAssert(storeName.length > 0, @"Store name is mandatory");

    NSString *fullStoreName = [storeName stringByAppendingString:@".sqlite"];
    NSURL *applicationSupportDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                                                inDomains:NSAllDomainsMask].firstObject;
    return [applicationSupportDirectory URLByAppendingPathComponent:fullStoreName isDirectory:NO];
}

#warning Untested
- (void)CDK_addSQLiteStoreWithURL:(NSURL *)storeURL automigrating:(BOOL)automigrating
{
    [self CDK_addSQLiteStoreWithoutRetryAtURL:storeURL automigrating:automigrating];

    // Workaround for "Migration failed after first pass" error
    if (automigrating && 0 == self.persistentStores.count)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self CDK_addSQLiteStoreWithoutRetryAtURL:storeURL automigrating:automigrating];
        });
    }
}

#pragma mark Private

- (void)CDK_addSQLiteStoreWithoutRetryAtURL:(NSURL *)storeURL automigrating:(BOOL)automigrating
{
    NSError *error;
    [self addPersistentStoreWithType:NSSQLiteStoreType
                       configuration:nil
                                 URL:storeURL
                             options:@{ NSMigratePersistentStoresAutomaticallyOption: @(automigrating),
                                        NSInferMappingModelAutomaticallyOption: @(automigrating),
                                        NSSQLitePragmasOption: @{@"journal_mode": @"WAL"} }
                               error:&error];
    CDKHandleError(error);
}

@end
