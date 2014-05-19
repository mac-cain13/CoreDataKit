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
#define CDKLogVerbose(msg, ...) { [[CDKDebugger sharedDebugger] log:@[[NSString stringWithFormat:msg, ##__VA_ARGS__]] atLevel:CDKDebuggerLogVerbose]; }
#define CDKLogInfo(msg, ...) { [[CDKDebugger sharedDebugger] log:@[[NSString stringWithFormat:msg, ##__VA_ARGS__]] atLevel:CDKDebuggerLogInfo]; }
#define CDKLogWarn(msg, ...) { [[CDKDebugger sharedDebugger] log:@[[NSString stringWithFormat:msg, ##__VA_ARGS__]] atLevel:CDKDebuggerLogWarning]; }
#define CDKLogError(msg, ...) { [[CDKDebugger sharedDebugger] log:@[[NSString stringWithFormat:msg, ##__VA_ARGS__]] atLevel:CDKDebuggerLogError]; }

/**
 `CDKDebugger` provides logging, error handling and other tricks.
 */
@interface CDKDebugger : NSObject

/**
 Messages at or above this level will be logged to the console.
 */
@property (nonatomic, assign) CDKDebuggerLogLevel logLevel;

/**
 If messages at or above this level are logged will halt execution of code and give you opportunity to debug and investigate.
 */
@property (nonatomic, assign) CDKDebuggerLogLevel breakOnLogLevel;

/**
 Shared debugger that is used by default.

 @return The globally available debugger
 */
+ (instancetype)sharedDebugger;

/**
 Handle a log message respecting the log level.

 @param messages Messages to log, should be `NSString` instances
 @param logLevel Level at which the message should be logged

 @return Action the debugger took
 */
- (CDKDebuggerAction)log:(NSArray *)messages atLevel:(CDKDebuggerLogLevel)logLevel;

/**
 Handle error class by logging and halting execution if required by the set levels.

 @param error Error to handle

 @return Action the debugger took
 */
- (CDKDebuggerAction)handleError:(NSError *)error;

@end
