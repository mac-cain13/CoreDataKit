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
        static var sharedPersistentCoordinator: NSPersistentStoreCoordinator?
    }

    var sharedPersistentCoordinator: NSPersistentStoreCoordinator {
        return Holder.sharedPersistentCoordinator!
    }

    override func setUp() {
        super.setUp()

        var optionalError: NSError?
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(NSBundle.allBundles())

        dispatch_once(&Holder.token) {
            Holder.sharedPersistentCoordinator = NSPersistentStoreCoordinator.coordinatorWithInMemoryStore(managedObjectModel: managedObjectModel, error: &optionalError)
            CoreDataKit.persistentStoreCoordinator = Holder.sharedPersistentCoordinator

            XCTAssertNil(optionalError, "ERROR: \(optionalError)")
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
