//
//  CoreDataStackTests.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import XCTest
import CoreData
import CoreDataKit

class CoreDataStackTests: TestCase {
  func testRootContext() {
    XCTAssertNil(coreDataStack.rootContext.parentContext, "Unexpected parent context")
    XCTAssertNotNil(coreDataStack.rootContext.persistentStoreCoordinator, "Missing persistent coordinator")
    XCTAssertEqual(coreDataStack.rootContext.persistentStoreCoordinator!, coreDataStack.persistentStoreCoordinator, "Incorrect persistent coordinator")
  }

  func testMainThreadContext() {
    XCTAssertNotNil(coreDataStack.mainThreadContext.persistentStoreCoordinator, "Missing persistent coordinator")
    XCTAssertEqual(coreDataStack.mainThreadContext.persistentStoreCoordinator!, coreDataStack.persistentStoreCoordinator, "Incorrect persistent coordinator")
    XCTAssertNotNil(coreDataStack.mainThreadContext.parentContext, "Missing parent context")
    XCTAssertEqual(coreDataStack.mainThreadContext.parentContext!, coreDataStack.rootContext, "Incorrect parent context")
  }

  func testDumpStack() {
    coreDataStack.dumpStack()
  }
}
