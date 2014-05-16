//
//  CDKTypes.h
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

/**
 Block used to perform save operations in the background. You're usually expected to make changes to objects on the given context. That context will save after your block is completed.

 @param context Context that will be saved
 */
typedef void (^CDKSaveBlock) (NSManagedObjectContext *context);

/**
 Block used to handle completion.

 @param error The error that occurred or nil if operation was successful
 */
typedef void (^CDKCompletionBlock) (NSError *error);
