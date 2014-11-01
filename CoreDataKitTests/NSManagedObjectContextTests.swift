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

// MARK: - Saving

    func testPerformBlockAndSaveToPersistentStore() {
        let completionExpectation = expectationWithDescription("Expected completion handler call")

        let countFRq = NSFetchRequest(entityName: "Employee")
        XCTAssertEqual(coreDataStack.rootContext.countForFetchRequest(countFRq, error: nil), 0, "Unexpected employee entities")

        coreDataStack.rootContext.createChildContext().performBlock({ (context) -> CommitAction in
            let employee: Employee = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as Employee
            employee.name = "Mike Ross"

            return .SaveToPersistentStore
        }, completionHandler: { (result) -> Void in
            XCTAssertNil(result.error(), "Unexpected error")
            XCTAssertEqual(self.coreDataStack.rootContext.countForFetchRequest(countFRq, error: nil), 1, "Unexpected employee entity count")
            completionExpectation.fulfill()
        })

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testFailingPerformBlockAndSaveToPersistentStore() {
        let completionExpectation = expectationWithDescription("Expected completion handler call")

        let countFRq = NSFetchRequest(entityName: "Employee")
        XCTAssertEqual(coreDataStack.rootContext.countForFetchRequest(countFRq, error: nil), 0, "Unexpected employee entities")

        coreDataStack.rootContext.createChildContext().performBlock({ (context) -> CommitAction in
            NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context)
            return .SaveToParentContext
        }, completionHandler: { (result) -> Void in
            XCTAssertNotNil(result.error(), "Expected error")
            XCTAssertEqual(result.error()!.code, 1570, "Incorrect error code")
            XCTAssertEqual(self.coreDataStack.rootContext.countForFetchRequest(countFRq, error: nil), 0, "Unexpected employee entities")
            completionExpectation.fulfill()
        })

        waitForExpectationsWithTimeout(3, handler: nil)
    }

// MARK: Obtaining permanent IDs

    func testObtainPermanentIDsForInsertedObjects() {
        let employee: Employee = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: coreDataStack.rootContext) as Employee
        employee.name = "Harvey Specter"

        XCTAssertTrue(employee.objectID.temporaryID, "Object ID must be temporary")

        switch coreDataStack.rootContext.obtainPermanentIDsForInsertedObjects() {
        case .Failure:
            XCTFail("Unexpected error")
        case .Success:
            XCTAssertFalse(employee.objectID.temporaryID, "Object ID must be permanent")
        }
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

// MARK: - Creating

    func testCreate() {
        switch coreDataStack.rootContext.create(Employee.self) {
        case let .Success(boxedEmployee):
            XCTAssertTrue(boxedEmployee().inserted, "Managed object should be inserted")
            XCTAssertEqual(boxedEmployee().managedObjectContext!, coreDataStack.rootContext, "Unexpected managed object context")
            break

        case .Failure:
            XCTFail("Unexpected error")
        }
    }

    func testCreateIncorrectEntityName() {
        switch coreDataStack.rootContext.create(EmployeeIncorrectEntityName.self) {
        case .Success:
            XCTFail("Unexpected managed object")
            break

        case let .Failure(error):
            XCTAssertEqual(error.domain, CoreDataKitErrorDomain, "Unexpected error domain")
            XCTAssertEqual(error.code, CoreDataKitErrorCode.EntityDescriptionNotFound.rawValue, "Unexpected error code")
        }
    }

// MARK: - Finding

    func testFindAllEmployeesWithOneEmployeeInserted() {
        switch coreDataStack.rootContext.create(Employee.self) {
        case .Failure:
            XCTFail("Unexpected error")

        case let .Success(boxedEmployee):
            boxedEmployee().name = "Rachel Zane"

            switch coreDataStack.rootContext.find(Employee.self) {
            case .Failure:
                XCTFail("Unexpected error")

            case let .Success(boxedResults):
                XCTAssertEqual(boxedResults().count, 1, "Incorrect number of results")

                if let firstEmployee = boxedResults().first {
                    XCTAssertEqual(firstEmployee.name, "Rachel Zane", "Incorrect employee name")
                }
            }
        }
    }

    func testFindEmployeesWithoutAnythingInserted() {
        switch coreDataStack.rootContext.find(Employee.self, predicate: nil, sortDescriptors: nil, limit: nil) {
        case .Failure:
            XCTFail("Unexpected error")

        case let .Success(boxedResults):
            XCTAssertEqual(boxedResults().count, 0, "Incorrect number of results")
        }
    }

    func testFindEmployeesWithFilteringAndSorting() {
        var optionalError: NSError?
        let optionalEmployees: (Result<Employee>, Result<Employee>, Result<Employee>) = (
            coreDataStack.rootContext.create(Employee.self),
            coreDataStack.rootContext.create(Employee.self),
            coreDataStack.rootContext.create(Employee.self)
        )

        switch optionalEmployees {
        case let (.Success(employee0), .Success(employee1), .Success(employee2)):
            employee0().name = "Rachel Zane 2"
            employee1().name = "Rachel Zane 1"
            employee2().name = "Mike Ross"

        default:
            XCTFail("Missing managed object")
        }

        let predicate = NSPredicate(format: "name contains %@", argumentArray: ["Rachel Zane"])
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        switch coreDataStack.rootContext.find(Employee.self, predicate: predicate, sortDescriptors: sortDescriptors, limit: nil) {
        case .Failure:
            XCTFail("Unexpected error")

        case let .Success(boxedResults):
            XCTAssertEqual(boxedResults().count, 2, "Incorrect number of results")
            XCTAssertEqual(boxedResults()[0].name, "Rachel Zane 1", "Incorrect order")
            XCTAssertEqual(boxedResults()[1].name, "Rachel Zane 2", "Incorrect order")
        }
    }
}

