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

        coreDataStack.rootContext.performBlockAndSaveToPersistentStore({ (context) -> Void in
            let employee: Employee = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as Employee
            employee.name = "Mike Ross"
        }, completionHandler: { (optionalError) -> Void in
            XCTAssertNil(optionalError, "Unexpected error")
            XCTAssertEqual(self.coreDataStack.rootContext.countForFetchRequest(countFRq, error: nil), 1, "Unexpected employee entity count")
            completionExpectation.fulfill()
        })

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testFailingPerformBlockAndSaveToPersistentStore() {
        let completionExpectation = expectationWithDescription("Expected completion handler call")

        let countFRq = NSFetchRequest(entityName: "Employee")
        XCTAssertEqual(coreDataStack.rootContext.countForFetchRequest(countFRq, error: nil), 0, "Unexpected employee entities")

        coreDataStack.rootContext.performBlockAndSaveToPersistentStore({ (context) -> Void in
            let employee: Employee = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as Employee
            }, completionHandler: { (optionalError) -> Void in
                XCTAssertNotNil(optionalError, "Expected error")
                XCTAssertEqual(optionalError!.code, 1570, "Incorrect error code")
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

// MARK: - Creating

    func testCreate() {
        var optionalError: NSError?
        let optionalEmployee = coreDataStack.rootContext.create(Employee.self, error: &optionalError)
        XCTAssertNotNil(optionalEmployee, "Missing managed object")
        XCTAssertNil(optionalError, "Unexpected error")

        if let employee = optionalEmployee {
            XCTAssertTrue(employee.inserted, "Managed object should be inserted")
            XCTAssertEqual(employee.managedObjectContext!, coreDataStack.rootContext, "Unexpected managed object context")
        }
    }

    func testCreateIncorrectEntityName() {
        var optionalError: NSError?
        let optionalEmployee = coreDataStack.rootContext.create(EmployeeIncorrectEntityName.self, error: &optionalError)
        XCTAssertNil(optionalEmployee, "Unexpected managed object")
        XCTAssertNotNil(optionalError, "Missing error")

        if let error = optionalError {
            XCTAssertEqual(error.domain, CoreDataKitErrorDomain, "Unexpected error domain")
            XCTAssertEqual(error.code, CoreDataKitErrorCode.EntityDescriptionNotFound.rawValue, "Unexpected error code")
        }
    }

    func testCreateIncorrectEntityNameWithoutErrorHandling() {
        let optionalEmployee = coreDataStack.rootContext.create(EmployeeIncorrectEntityName.self, error: nil)
        XCTAssertNil(optionalEmployee, "Unexpected managed object")
    }

// MARK: - Finding

    func testAllEmployeesWithOneEmployeeInserted() {
        var optionalError: NSError?
        let optionalEmployee = coreDataStack.rootContext.create(Employee.self, error: &optionalError)
        XCTAssertNotNil(optionalEmployee, "Missing managed object")
        XCTAssertNil(optionalError, "Unexpected error")

        if let employee = optionalEmployee {
            employee.name = "Rachel Zane"

            let optionalAllEmployees: [Employee]? = coreDataStack.rootContext.all(Employee.self, error: nil)
            XCTAssertNotNil(optionalAllEmployees, "Missing results")

            if let allEmployees = optionalAllEmployees {
                XCTAssertEqual(allEmployees.count, 1, "Incorrect number of results")

                if let firstEmployee = allEmployees.first {
                    XCTAssertEqual(firstEmployee.name, "Rachel Zane", "Incorrect employee name")
                }
            }
        }
    }

    func testFindEmployeesWithoutAnythingInserted() {
        var optionalError: NSError?
        let optionalAllEmployees = coreDataStack.rootContext.find(Employee.self, predicate: nil, sortDescriptors: nil, limit: nil, error: &optionalError)
        XCTAssertNotNil(optionalAllEmployees, "Missing results")
        XCTAssertNil(optionalError, "Unexpected error")

        if let allEmployees = optionalAllEmployees {
            XCTAssertEqual(allEmployees.count, 0, "Incorrect number of results")
        }
    }

    func testFindEmployeesWithFilteringAndSorting() {
        var optionalError: NSError?
        let optionalEmployees: (Employee?, Employee?, Employee?) = (
            coreDataStack.rootContext.create(Employee.self, error: &optionalError),
            coreDataStack.rootContext.create(Employee.self, error: &optionalError),
            coreDataStack.rootContext.create(Employee.self, error: &optionalError)
        )
        XCTAssertNil(optionalError, "Unexpected error")

        switch optionalEmployees {
        case let (.Some(employee0), .Some(employee1), .Some(employee2)):
            employee0.name = "Rachel Zane 2"
            employee1.name = "Rachel Zane 1"
            employee2.name = "Mike Ross"

        default:
            XCTFail("Missing managed object")
        }

        let predicate = NSPredicate(format: "name contains %@", argumentArray: ["Rachel Zane"])
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let optionalFoundEmployees: [Employee]? = coreDataStack.rootContext.find(Employee.self, predicate: predicate, sortDescriptors: sortDescriptors, limit: nil, error: &optionalError)
        XCTAssertNil(optionalError, "Unexpected error")
        XCTAssertNotNil(optionalFoundEmployees, "Missing results")

        if let foundEmployees = optionalFoundEmployees {
            XCTAssertEqual(foundEmployees.count, 2, "Incorrect number of results")

            XCTAssertEqual(foundEmployees[0].name, "Rachel Zane 1", "Incorrect order")
            XCTAssertEqual(foundEmployees[1].name, "Rachel Zane 2", "Incorrect order")
        }
    }
}

