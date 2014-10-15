//
//  TestCase.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 15-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import XCTest
import CoreData
import CoreDataKit

class TestCase: XCTestCase {
    private struct Holder {
        static var token: dispatch_once_t = 0
        static var coreDataStack: CoreDataStack?
    }

    var coreDataStack: CoreDataStack {
        return Holder.coreDataStack!
    }

    override func setUp() {
        super.setUp()

        var optionalError: NSError?
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(NSBundle.allBundles())

        // Setup the shared stack
        dispatch_once(&Holder.token) {
            let persistentCoordinator = NSPersistentStoreCoordinator.coordinatorWithInMemoryStore(managedObjectModel: managedObjectModel, error: &optionalError)
            XCTAssertNil(optionalError, "ERROR: \(optionalError)")

            CoreDataKit.sharedStack = CoreDataStack(persistentStoreCoordinator: persistentCoordinator!)
        }

        // Setup the stack for this test
        let persistentCoordinator = NSPersistentStoreCoordinator.coordinatorWithInMemoryStore(managedObjectModel: managedObjectModel, error: &optionalError)
        XCTAssertNil(optionalError, "ERROR: \(optionalError)")

        Holder.coreDataStack = CoreDataStack(persistentStoreCoordinator: persistentCoordinator!)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
