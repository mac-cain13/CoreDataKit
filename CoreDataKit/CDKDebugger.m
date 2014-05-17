//
//  CoreDataKitDebugger.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import "CDKDebugger.h"

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

        case CDKDebuggerLogWarn:
            string = @"Warn";
            break;

        case CDKDebuggerLogError:
            string = @"Error";
            break;
    }
    
    return string;
}

@implementation CDKDebugger

#warning Tests missing
+ (instancetype)sharedDebugger
{
    static CDKDebugger *sharedDebugger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDebugger = [[CDKDebugger alloc] init];
    });

    return sharedDebugger;
}

#warning Tests missing
- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

#ifdef DEBUG
    self.logLevel = CDKDebuggerLogWarn;
    self.breakOnLogLevel = CDKDebuggerLogError;
#else
    self.logLevel = CDKDebuggerLogSilent;
    self.breakOnLogLevel = CDKDebuggerLogSilent;
#endif

    return self;
}

#warning Tests missing
- (void)log:(CDKDebuggerLogLevel)logLevel message:(NSString *)message
{
    // Log message if required by log level
    if (self.logLevel != CDKDebuggerLogSilent && logLevel >= self.logLevel)
    {
        NSLog(@"[CoreDataKit] Log from %@:", NSStringFromSelector(_cmd));
        NSLog(@"[CoreDataKit] %@: %@", NSStringFromCDKDebuggerLogLevel(logLevel), message);
    }

    // Break execution if required by log level
    if (self.breakOnLogLevel != CDKDebuggerLogSilent && logLevel >= self.breakOnLogLevel)
    {
        CDKBreak(@"[CoreDataKit] CDKDebugger will now break so you can investigate.");
    }
}

#warning Tests missing
- (void)handleError:(NSError *)error
{
#warning Unimplemented method
}

@end
