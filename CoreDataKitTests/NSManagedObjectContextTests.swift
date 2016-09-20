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

    XCTAssertNil(context.parent, "Unexpected parent context")
    XCTAssertNotNil(context.persistentStoreCoordinator, "Missing persistent coordinator")
    XCTAssertEqual(context.persistentStoreCoordinator!, coreDataStack.persistentStoreCoordinator, "Incorrect persistent coordinator")
    XCTAssertEqual(context.concurrencyType, NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType, "Incorrect concurrency type")
  }

  func testInitWithPersistentStoreObtainsPermanentIDs() {
    let context = NSManagedObjectContext(persistentStoreCoordinator: coreDataStack.persistentStoreCoordinator)
    testContextObtainsPermanentIDs(context: context)
  }

  func testInitWithParentContext() {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType, parentContext: coreDataStack.rootContext)

    XCTAssertNotNil(context.parent, "Missing parent context")
    XCTAssertEqual(context.parent!, coreDataStack.rootContext, "Incorrect parent context")
    XCTAssertEqual(context.concurrencyType, NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType, "Incorrect concurrency type")
  }

  func testInitWithParentContextObtainsPermanentIDs() {
    let parentContext = NSManagedObjectContext(persistentStoreCoordinator: coreDataStack.persistentStoreCoordinator)
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType, parentContext: parentContext)
    testContextObtainsPermanentIDs(context: context)
  }

  // MARK: - Saving

  func testPerformBlockAndSaveToPersistentStore() {
    let completionExpectation = expectation(description: "Expected completion handler call")

    let countFRq = NSFetchRequest<NSManagedObject>(entityName: "Employee")
    XCTAssertEqual(try? coreDataStack.rootContext.count(for: countFRq), 0, "Unexpected employee entities")

    coreDataStack.backgroundContext.perform(block: { (context) -> CommitAction in
      let employee: Employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as! Employee
      employee.name = "Mike Ross"

      return .saveToPersistentStore
      }, completionHandler: { (result) -> Void in
        do {
          _ = try result()
          XCTAssertEqual(try self.coreDataStack.rootContext.count(for: countFRq), 1, "Unexpected employee entity count")
          completionExpectation.fulfill()
        }
        catch {
          XCTFail("Unexpected error")
        }
    })

    waitForExpectations(timeout: 3, handler: nil)
  }

  func testFailingPerformBlockAndSaveToPersistentStore() {
    let completionExpectation = expectation(description: "Expected completion handler call")

    let countFRq = NSFetchRequest<NSManagedObject>(entityName: "Employee")
    XCTAssertEqual(try? coreDataStack.rootContext.count(for: countFRq), 0, "Unexpected employee entities")

    coreDataStack.backgroundContext.perform(block: { (context) -> CommitAction in
      NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context)
      return .saveToParentContext
      }, completionHandler: { (result) -> Void in
        do {
          _ = try result()
          XCTFail("Expected error")
        }
        catch CoreDataKitError.coreDataError(let error) {
          XCTAssertEqual((error as NSError).code, 1570, "Incorrect error code")
          XCTAssertEqual(try? self.coreDataStack.rootContext.count(for: countFRq), 0, "Unexpected employee entities")
          completionExpectation.fulfill()
        }
        catch {
          XCTFail("Unexpected error")
        }
    })

    waitForExpectations(timeout: 3, handler: nil)
  }

  // MARK: Obtaining permanent IDs

  func testObtainPermanentIDsForInsertedObjects() {
    let employee: Employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: coreDataStack.rootContext) as! Employee
    employee.name = "Harvey Specter"

    XCTAssertTrue(employee.objectID.isTemporaryID, "Object ID must be temporary")

    do {
      try coreDataStack.rootContext.obtainPermanentIDsForInsertedObjects()
      XCTAssertFalse(employee.objectID.isTemporaryID, "Object ID must be permanent")
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  private func testContextObtainsPermanentIDs(context: NSManagedObjectContext) {
    let saveExpectation = expectation(description: "Await save result")

    var employee: Employee!
    context.perform(block: { context in
      employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as! Employee
      employee.name = "Harvey Specter"

      XCTAssertTrue(employee.objectID.isTemporaryID, "Object ID must be temporary")

      return .saveToParentContext
      }, completionHandler: { _ in
        XCTAssertFalse(employee.objectID.isTemporaryID, "Object ID must be permanent")
        saveExpectation.fulfill()
    })

    waitForExpectations(timeout: 3, handler: nil)
  }

  // MARK: - Creating

  func testCreate() {
    do {
      let employee = try coreDataStack.rootContext.create(Employee.self)
      XCTAssertTrue(employee.isInserted, "Managed object should be inserted")
      XCTAssertEqual(employee.managedObjectContext!, coreDataStack.rootContext, "Unexpected managed object context")
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  func testCreateIncorrectEntityName() {
    do {
      _ = try coreDataStack.rootContext.create(EmployeeIncorrectEntityName.self)
      XCTFail("Unexpected managed object")
    }
    catch CoreDataKitError.contextError {
      // Expected error
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  // MARK: - Finding

  func testFindAllEmployeesWithOneEmployeeInserted() {
    do {
      let employee = try coreDataStack.rootContext.create(Employee.self)
      employee.name = "Rachel Zane"

      let results = try coreDataStack.rootContext.find(Employee.self)
      XCTAssertEqual(results.count, 1, "Incorrect number of results")

      if let firstEmployee = results.first {
        XCTAssertEqual(firstEmployee.name, "Rachel Zane", "Incorrect employee name")
      }
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  func testFindEmployeesWithoutAnythingInserted() {
    do {
      let results = try coreDataStack.rootContext.find(Employee.self, predicate: nil, sortDescriptors: nil, limit: nil)
      XCTAssertEqual(results.count, 0, "Incorrect number of results")
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  func testFindEmployeesWithFilteringAndSorting() {
    do {
      let employee0 = try coreDataStack.rootContext.create(Employee.self)
      let employee1 = try coreDataStack.rootContext.create(Employee.self)
      let employee2 = try coreDataStack.rootContext.create(Employee.self)

      employee0.name = "Rachel Zane 2"
      employee1.name = "Rachel Zane 1"
      employee2.name = "Mike Ross"
    }
    catch {
      XCTFail("Missing managed object")
    }

    let predicate = NSPredicate(format: "name contains %@", argumentArray: ["Rachel Zane"])
    let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

    do {
      let results = try coreDataStack.rootContext.find(Employee.self, predicate: predicate, sortDescriptors: sortDescriptors, limit: nil)

      XCTAssertEqual(results.count, 2, "Incorrect number of results")
      XCTAssertEqual(results[0].name, "Rachel Zane 1", "Incorrect order")
      XCTAssertEqual(results[1].name, "Rachel Zane 2", "Incorrect order")
    }
    catch {
      XCTFail("Unexpected error")
    }
  }
}

