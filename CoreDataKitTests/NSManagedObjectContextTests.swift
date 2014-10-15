//
//  NSManagedObjectTests.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 15-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import XCTest
import CoreData
import CoreDataKit

class NSManagedObjectContextTests: TestCase {
    func testInitWithPersistentStore() {
        let context = NSManagedObjectContext(persistentStoreCoordinator: coreDataStack.persistentStoreCoordinator)

        XCTAssertNil(context.parentContext, "Unexpected parent context")
        XCTAssertNotNil(context.persistentStoreCoordinator, "Missing persistent coordinator")
        XCTAssertEqual(context.persistentStoreCoordinator!, coreDataStack.persistentStoreCoordinator, "Incorrect persistent coordinator")
        XCTAssertEqual(context.concurrencyType, NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType, "Incorrect concurrency type")
    }

    func testInitWithPersistentStoreObtainsPermanentIDs() {
        let context = NSManagedObjectContext(persistentStoreCoordinator: coreDataStack.persistentStoreCoordinator)
        testContextObtainsPermanentIDs(context)
    }

    func testInitWithParentContext() {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType, parentContext: coreDataStack.rootContext)

        XCTAssertNotNil(context.parentContext, "Missing parent context")
        XCTAssertEqual(context.parentContext!, coreDataStack.rootContext, "Incorrect parent context")
        XCTAssertEqual(context.concurrencyType, NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType, "Incorrect concurrency type")
    }

    func testInitWithParentContextObtainsPermanentIDs() {
        let parentContext = NSManagedObjectContext(persistentStoreCoordinator: coreDataStack.persistentStoreCoordinator)
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType, parentContext: parentContext)
        testContextObtainsPermanentIDs(context)
    }

    func testPerformBlockAndSaveToPersistentStore() {
        let completionExpectation = expectationWithDescription("Expected completion handler call")

        coreDataStack.rootContext.performBlockAndSaveToPersistentStore({ (context) -> Void in
            let employee: Employee = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as Employee
            employee.name = "Mike Ross"
        }, completionHandler: { (optionalError) -> Void in
            XCTAssertNil(optionalError, "Unexpected error")
            completionExpectation.fulfill()
        })

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testFailingPerformBlockAndSaveToPersistentStore() {
        let completionExpectation = expectationWithDescription("Expected completion handler call")

        coreDataStack.rootContext.performBlockAndSaveToPersistentStore({ (context) -> Void in
            let employee: Employee = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as Employee
            }, completionHandler: { (optionalError) -> Void in
                XCTAssertNotNil(optionalError, "Expected error")
                XCTAssertEqual(optionalError!.code, 1570, "Incorrect error code")
                completionExpectation.fulfill()
        })

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testObtainPermanentIDsForInsertedObjects() {
        let employee: Employee = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: coreDataStack.rootContext) as Employee
        employee.name = "Harvey Specter"

        XCTAssertTrue(employee.objectID.temporaryID, "Object ID must be temporary")
        var optionalError: NSError?
        coreDataStack.rootContext.obtainPermanentIDsForInsertedObjects(&optionalError)
        XCTAssertNil(optionalError, "Unexpected error")
        XCTAssertFalse(employee.objectID.temporaryID, "Object ID must be permanent")
    }

    private func testContextObtainsPermanentIDs(context: NSManagedObjectContext) {
        let employee: Employee = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as Employee
        employee.name = "Harvey Specter"

        XCTAssertTrue(employee.objectID.temporaryID, "Object ID must be temporary")
        var optionalError: NSError?
        context.save(&optionalError)
        XCTAssertNil(optionalError, "Unexpected error")
        XCTAssertFalse(employee.objectID.temporaryID, "Object ID must be permanent")
    }
}

