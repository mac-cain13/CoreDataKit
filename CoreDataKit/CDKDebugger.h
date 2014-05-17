//
//  CDKDebugger.h
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDKTypes.h"

// Macros for easy logging with the shared debugger
#define CDKHandleError(error)   { [[CDKDebugger sharedDebugger] handleError:error]; }
#define CDKLogVerbose(msg, ...) { [[CDKDebugger sharedDebugger] log:CoreDataKitDebuggerLogVerbose message:[NSString stringWithFormat:msg, ##__VA_ARGS__]]; }
#define CDKLogInfo(msg, ...) { [[CDKDebugger sharedDebugger] log:CoreDataKitDebuggerLogInfo message:[NSString stringWithFormat:msg, ##__VA_ARGS__]]; }
#define CDKLogWarn(msg, ...) { [[CDKDebugger sharedDebugger] log:CoreDataKitDebuggerLogWarn message:[NSString stringWithFormat:msg, ##__VA_ARGS__]]; }
#define CDKLogError(msg, ...) { [[CDKDebugger sharedDebugger] log:CoreDataKitDebuggerLogError message:[NSString stringWithFormat:msg, ##__VA_ARGS__]]; }

/**
 `CDKDebugger` provides logging, error handling and other tricks.
 */
@interface CDKDebugger : NSObject

/**
 Messages at or above this level will be logged to the console.
 */
@property (nonatomic, assign) CDKDebuggerLogLevel logLevel;

/**
 Messages at or above this level will halt execution of code and give you opportunity to debug and investigate.
 */
@property (nonatomic, assign) CDKDebuggerLogLevel breakOnLogLevel;

/**
 Shared debugger that is used by default.

 @return The globally available debugger
 */
+ (instancetype)sharedDebugger;

/**
 Handle a log message respecting the log level.

 @param logLevel Level at which the message should be logged
 @param message  Message to log
 */
- (void)log:(CDKDebuggerLogLevel)logLevel message:(NSString *)message;

/**
 Handle error class by logging and halting execution if required by the set levels.

 @param error Error to handle
 */
- (void)handleError:(NSError *)error;

@end
