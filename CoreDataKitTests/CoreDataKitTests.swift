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

    func testBackgroundContext() {
        XCTAssertNotNil(CoreDataKit.backgroundContext.persistentStoreCoordinator, "Missing persistent coordinator")
        XCTAssertEqual(CoreDataKit.backgroundContext.persistentStoreCoordinator!, CoreDataKit.persistentStoreCoordinator, "Incorrect persistent coordinator")
        XCTAssertNotNil(CoreDataKit.backgroundContext.parentContext, "Missing parent context")
        XCTAssertEqual(CoreDataKit.backgroundContext.parentContext!, CoreDataKit.sharedStack!.rootContext, "Incorrect parent context")
    }

    func testMainThreadContext() {
        XCTAssertNotNil(CoreDataKit.mainThreadContext.persistentStoreCoordinator, "Missing persistent coordinator")
        XCTAssertEqual(CoreDataKit.mainThreadContext.persistentStoreCoordinator!, CoreDataKit.persistentStoreCoordinator, "Incorrect persistent coordinator")
        XCTAssertNotNil(CoreDataKit.mainThreadContext.parentContext, "Missing parent context")
        XCTAssertEqual(CoreDataKit.mainThreadContext.parentContext!, CoreDataKit.sharedStack!.rootContext, "Incorrect parent context")
    }
}
