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
        XCTAssertEqual(CDK.persistentStoreCoordinator, CDK.sharedStack!.persistentStoreCoordinator, "Incorrect persistent coordinator")
    }

    func testBackgroundContext() {
        XCTAssertNotNil(CDK.backgroundContext.persistentStoreCoordinator, "Missing persistent coordinator")
        XCTAssertEqual(CDK.backgroundContext.persistentStoreCoordinator!, CDK.persistentStoreCoordinator, "Incorrect persistent coordinator")
        XCTAssertNotNil(CDK.backgroundContext.parentContext, "Missing parent context")
        XCTAssertEqual(CDK.backgroundContext.parentContext!, CDK.sharedStack!.rootContext, "Incorrect parent context")
    }

    func testMainThreadContext() {
        XCTAssertNotNil(CDK.mainThreadContext.persistentStoreCoordinator, "Missing persistent coordinator")
        XCTAssertEqual(CDK.mainThreadContext.persistentStoreCoordinator!, CDK.persistentStoreCoordinator, "Incorrect persistent coordinator")
        XCTAssertNotNil(CDK.mainThreadContext.parentContext, "Missing parent context")
        XCTAssertEqual(CDK.mainThreadContext.parentContext!, CDK.sharedStack!.rootContext, "Incorrect parent context")
    }
}
