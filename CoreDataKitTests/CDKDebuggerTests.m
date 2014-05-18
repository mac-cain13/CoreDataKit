//
//  CDKDebuggerTests.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <XCTest/XCTest.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#import "CDKDebugger.h"

@interface CDKDebuggerTests : XCTestCase

@property (strong, nonatomic) CDKDebugger *debugger;

@end

@implementation CDKDebuggerTests

- (void)setUp
{
    [super setUp];
    self.debugger = [[CDKDebugger alloc] init];
}

- (void)tearDown
{
    self.debugger = nil;
    [super tearDown];
}

#pragma mark - Singleton

- (void)testSingletonNotNil
{
    XCTAssertNotNil([CDKDebugger sharedDebugger], @"sharedDebugger shouldn't be nil");
}

- (void)testSingletonReturnsSameObject
{
    XCTAssertEqual([CDKDebugger sharedDebugger], [CDKDebugger sharedDebugger], @"sharedDebugger should return same instance twice");
}

#pragma mark - Defaults

- (void)testDefaultLogLevel
{
    XCTAssertEqual(self.debugger.logLevel, CDKDebuggerLogWarning, @"Default log level should be warn");
}

- (void)testDefaultBreakOnLogLevel
{
    XCTAssertEqual(self.debugger.breakOnLogLevel, CDKDebuggerLogError, @"Default break on log level should be error");
}

#pragma mark - Log handling

- (void)testLogAtLevelBreakHigherThanLog
{
    self.debugger.logLevel = CDKDebuggerLogWarning;
    self.debugger.breakOnLogLevel = CDKDebuggerLogError;

    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogSilent], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogVerbose], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogInfo], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogWarning], CDKDebuggerActionLogged, @"Debugger should take log action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogError], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should take break and log action");
}

- (void)testLogAtLevelLogHigherThanBreak
{
    self.debugger.logLevel = CDKDebuggerLogError;
    self.debugger.breakOnLogLevel = CDKDebuggerLogWarning;

    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogSilent], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogVerbose], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogInfo], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogWarning], CDKDebuggerActionBreakpoint, @"Debugger should take break action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogError], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should take break and log action");
}

- (void)testLogAtLevelBothSilent
{
    self.debugger.logLevel = CDKDebuggerLogSilent;
    self.debugger.breakOnLogLevel = CDKDebuggerLogSilent;

    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogSilent], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogVerbose], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogInfo], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogWarning], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogError], CDKDebuggerActionNone, @"Debugger should not take action");
}

- (void)testLogAtLevelBothVerbose
{
    self.debugger.logLevel = CDKDebuggerLogVerbose;
    self.debugger.breakOnLogLevel = CDKDebuggerLogVerbose;

    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogSilent], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogVerbose], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should take break and log action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogInfo], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should take break and log action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogWarning], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should take break and log action");
    XCTAssertEqual([self.debugger log:@[@"Test"] atLevel:CDKDebuggerLogError], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should take break and log action");
}

#pragma mark - Error handling

- (void)testErrorHandlingWithNil
{
    self.debugger.logLevel = CDKDebuggerLogVerbose;
    self.debugger.breakOnLogLevel = CDKDebuggerLogVerbose;

    XCTAssertEqual([self.debugger handleError:nil], CDKDebuggerActionNone, @"Debugger should not take action ");
}

- (void)testErrorHandlingWithLogLevelSilent
{
    self.debugger.logLevel = CDKDebuggerLogSilent;
    self.debugger.breakOnLogLevel = CDKDebuggerLogSilent;

    XCTAssertEqual([self.debugger handleError:mock([NSError class])], CDKDebuggerActionNone, @"Debugger should not take action ");
}

- (void)testErrorHandlingWithLogLevelWarn
{
    self.debugger.logLevel = CDKDebuggerLogWarning;
    self.debugger.breakOnLogLevel = CDKDebuggerLogSilent;

    XCTAssertEqual([self.debugger handleError:mock([NSError class])], CDKDebuggerActionLogged, @"Debugger should take log action ");
}

- (void)testErrorHandlingWithLogLevelError
{
    self.debugger.logLevel = CDKDebuggerLogError;
    self.debugger.breakOnLogLevel = CDKDebuggerLogSilent;

    XCTAssertEqual([self.debugger handleError:mock([NSError class])], CDKDebuggerActionLogged, @"Debugger should take log action ");
}

@end
