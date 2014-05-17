//
//  CDKTypes.h
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

@class NSManagedObjectContext;

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

/**
 Log levels as used by the `CoreDataKitDebugger`
 */
typedef NS_ENUM(NSUInteger, CDKDebuggerLogLevel) {
    /**
     Level to indicate that no logs should show up
     */
    CDKDebuggerLogSilent    = 0,
    /**
     Level for detailed debug messages about what CoreDataKit is doing
     */
    CDKDebuggerLogVerbose   = 1,
    /**
     Level for messages about what CoreDataKit is doing
     */
    CDKDebuggerLogInfo      = 2,
    /**
     Level for messages about stuff that could lead to an error
     */
    CDKDebuggerLogWarn      = 3,
    /**
     Level for messages about things that did fail
     */
    CDKDebuggerLogError     = 4
};

// Macros for easy logging with the shared debugger
#define CDKHandleError(error)   { [[CoreDataKitDebugger sharedDebugger] handleError:error]; }
#define CDKLogVerbose(msg, ...) { [[CoreDataKitDebugger sharedDebugger] log:CoreDataKitDebuggerLogVerbose message:[NSString stringWithFormat:msg, ##__VA_ARGS__]]; }
#define CDKLogInfo(msg, ...) { [[CoreDataKitDebugger sharedDebugger] log:CoreDataKitDebuggerLogInfo message:[NSString stringWithFormat:msg, ##__VA_ARGS__]]; }
#define CDKLogWarn(msg, ...) { [[CoreDataKitDebugger sharedDebugger] log:CoreDataKitDebuggerLogWarn message:[NSString stringWithFormat:msg, ##__VA_ARGS__]]; }
#define CDKLogError(msg, ...) { [[CoreDataKitDebugger sharedDebugger] log:CoreDataKitDebuggerLogError message:[NSString stringWithFormat:msg, ##__VA_ARGS__]]; }
