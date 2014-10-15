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

class CoreDataKitTests: XCTestCase {
    class var coordinator: NSPersistentStoreCoordinator {
        struct Singleton {
            static let instance = NSPersistentStoreCoordinator()
        }

        return Singleton.instance
    }
    
    override func setUp() {
        super.setUp()

        if CoreDataKit.persistentStoreCoordinator == nil {
            CoreDataKit.persistentStoreCoordinator = CoreDataKitTests.coordinator
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPersistentStoreCoordinator() {
        XCTAssertNotNil(CoreDataKit.persistentStoreCoordinator, "Missing persistent coordinator")
        XCTAssertEqual(CoreDataKit.persistentStoreCoordinator!, CoreDataKitTests.coordinator, "CoreDataKit.persistentStoreCoordinator didn't return correct coordinator")
    }

    func testRootContext() {
        XCTAssertNil(CoreDataKit.rootContext.parentContext, "Unexpected parent context")
        XCTAssertNotNil(CoreDataKit.rootContext.persistentStoreCoordinator, "Missing persistent coordinator")
        XCTAssertEqual(CoreDataKit.rootContext.persistentStoreCoordinator!, CoreDataKit.persistentStoreCoordinator!, "Incorrect persistent coordinator")
    }

    func testMainThreadContext() {
        XCTAssertNotNil(CoreDataKit.mainThreadContext.persistentStoreCoordinator, "Missing persistent coordinator")
        XCTAssertEqual(CoreDataKit.mainThreadContext.persistentStoreCoordinator!, CoreDataKit.persistentStoreCoordinator!, "Incorrect persistent coordinator")
        XCTAssertNotNil(CoreDataKit.mainThreadContext.parentContext, "Missing parent context")
        XCTAssertEqual(CoreDataKit.mainThreadContext.parentContext!, CoreDataKit.rootContext, "Incorrect parent context")
    }
}
