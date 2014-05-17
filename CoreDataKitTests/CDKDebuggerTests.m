//
//  CDKDebuggerTests.m
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <XCTest/XCTest.h>
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

#pragma mark - Logging and error handling

- (void)testLogAtLevelBreakHigherThanLog
{
    self.debugger.logLevel = CDKDebuggerLogWarning;
    self.debugger.breakOnLogLevel = CDKDebuggerLogError;

    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogSilent], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogVerbose], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogInfo], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogWarning], CDKDebuggerActionLogged, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogError], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should not take action");
}

- (void)testLogAtLevelLogHigherThanBreak
{
    self.debugger.logLevel = CDKDebuggerLogError;
    self.debugger.breakOnLogLevel = CDKDebuggerLogWarning;

    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogSilent], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogVerbose], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogInfo], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogWarning], CDKDebuggerActionBreakpoint, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogError], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should not take action");
}

- (void)testLogAtLevelBothSilent
{
    self.debugger.logLevel = CDKDebuggerLogSilent;
    self.debugger.breakOnLogLevel = CDKDebuggerLogSilent;

    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogSilent], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogVerbose], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogInfo], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogWarning], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogError], CDKDebuggerActionNone, @"Debugger should not take action");
}

- (void)testLogAtLevelBothVerbose
{
    self.debugger.logLevel = CDKDebuggerLogVerbose;
    self.debugger.breakOnLogLevel = CDKDebuggerLogVerbose;

    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogSilent], CDKDebuggerActionNone, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogVerbose], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogInfo], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogWarning], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should not take action");
    XCTAssertEqual([self.debugger log:@[@""] atLevel:CDKDebuggerLogError], CDKDebuggerActionBreakpoint|CDKDebuggerActionLogged, @"Debugger should not take action");
}

@end
