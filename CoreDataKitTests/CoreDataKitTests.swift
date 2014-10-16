//
//  CoreDataKitTests.swift
//  CoreDataKitTests
//
//  Created by Mathijs Kadijk on 23-06-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import XCTest
import CoreData
import CoreDataKit

class CoreDataKitTests: TestCase {
    func testPersistentStoreCoordinator() {
        XCTAssertEqual(CoreDataKit.persistentStoreCoordinator, CoreDataKit.sharedStack!.persistentStoreCoordinator, "Incorrect persistent coordinator")
    }

    func testRootContext() {
        XCTAssertNil(CoreDataKit.rootContext.parentContext, "Unexpected parent context")
        XCTAssertNotNil(CoreDataKit.rootContext.persistentStoreCoordinator, "Missing persistent coordinator")
        XCTAssertEqual(CoreDataKit.rootContext.persistentStoreCoordinator!, CoreDataKit.persistentStoreCoordinator, "Incorrect persistent coordinator")
    }

    func testMainThreadContext() {
        XCTAssertNotNil(CoreDataKit.mainThreadContext.persistentStoreCoordinator, "Missing persistent coordinator")
        XCTAssertEqual(CoreDataKit.mainThreadContext.persistentStoreCoordinator!, CoreDataKit.persistentStoreCoordinator, "Incorrect persistent coordinator")
        XCTAssertNotNil(CoreDataKit.mainThreadContext.parentContext, "Missing parent context")
        XCTAssertEqual(CoreDataKit.mainThreadContext.parentContext!, CoreDataKit.rootContext, "Incorrect parent context")
    }
}
