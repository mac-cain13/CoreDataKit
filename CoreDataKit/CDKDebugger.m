//
//  CoreDataKitDebugger.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import "CDKDebugger.h"
#import "CDKTypes.h"

#ifdef DEBUG
#define CDKBreak(msg, ...)  { NSLog(msg, ##__VA_ARGS__); kill(getpid(), SIGINT); }
#else
#define CDKBreak(msg, ...)  {}
#endif

static NSString *NSStringFromCDKDebuggerLogLevel(CDKDebuggerLogLevel logLevel)
{
    NSString *string = @"Unknown";

    switch (logLevel) {
        case CDKDebuggerLogSilent:
            string = @"Silent";
            break;

        case CDKDebuggerLogVerbose:
            string = @"Verbose";
            break;

        case CDKDebuggerLogInfo:
            string = @"Info";
            break;

        case CDKDebuggerLogWarning:
            string = @"Warning";
            break;

        case CDKDebuggerLogError:
            string = @"Error";
            break;
    }
    
    return string;
}

@implementation CDKDebugger

+ (instancetype)sharedDebugger
{
    static CDKDebugger *sharedDebugger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDebugger = [[CDKDebugger alloc] init];
    });

    return sharedDebugger;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

#ifdef DEBUG
    self.logLevel = CDKDebuggerLogWarning;
    self.breakOnLogLevel = CDKDebuggerLogError;
#else
    self.logLevel = CDKDebuggerLogSilent;
    self.breakOnLogLevel = CDKDebuggerLogSilent;
#endif

    return self;
}

- (CDKDebuggerAction)log:(NSArray *)messages atLevel:(CDKDebuggerLogLevel)logLevel
{
    CDKDebuggerAction actions = CDKDebuggerActionNone;

    // Log message if required by log level
    if (CDKDebuggerLogSilent != self.logLevel && logLevel >= self.logLevel)
    {
        [messages enumerateObjectsUsingBlock:^(NSString *message, NSUInteger idx, BOOL *stop) {
            NSLog(@"[CoreDataKit] %@ %@", NSStringFromCDKDebuggerLogLevel(logLevel).uppercaseString, message);
        }];
        actions = actions | CDKDebuggerActionLogged;
    }

    // Break execution if required by log level
    if (CDKDebuggerLogSilent != self.breakOnLogLevel && logLevel >= self.breakOnLogLevel)
    {
        CDKBreak(@"[CoreDataKit] CDKDebugger will now break so you can investigate.");
        actions = actions | CDKDebuggerActionBreakpoint;
    }

    return actions;
}

- (CDKDebuggerAction)handleError:(NSError *)error
{
    CDKDebuggerAction actions = CDKDebuggerActionNone;

    if (error)
    {
        #warning Should check if we this error logging is to our liking
        NSMutableArray *messages = @[].mutableCopy;

        // Log all values in the user info dict, also iterate over arrays/errors in the dict
        [error.userInfo.allValues enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
            if ([value isKindOfClass:[NSArray class]])
            {
                [value enumerateObjectsUsingBlock:^(id valueInArray, NSUInteger idxInArray, BOOL *stopInArray) {
                    id valueToLog = ([valueInArray respondsToSelector:@selector(userInfo)]) ? [valueInArray userInfo] : valueInArray;
                    [messages addObject:[NSString stringWithFormat:@"Error Details: %@", valueToLog]];
                }];
            }
            else
            {
                [messages addObject:[NSString stringWithFormat:@"Error: %@", value]];
            }
        }];

        // Log error info
        [messages addObject:[NSString stringWithFormat:@"Error Message: %@", error.localizedDescription]];
        [messages addObject:[NSString stringWithFormat:@"Error Domain: %@", error.domain]];
        [messages addObject:[NSString stringWithFormat:@"Recovery Suggestion: %@", error.localizedRecoverySuggestion]];

        actions = [self log:messages atLevel:CDKDebuggerLogError];
    }

    return actions;
}

@end
