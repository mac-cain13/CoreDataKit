//
//  NSPersistentStoreCoordinatorTests.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import XCTest
import CoreData
import CoreDataKit

class NSPersistentStoreCoordinatorTests: TestCase {
  func testInitializationSQLiteStore() {
    let optionalCoordinator = NSPersistentStoreCoordinator(automigrating: true)
    XCTAssertNotNil(optionalCoordinator, "Missing coordinator")

    if let coordinator = optionalCoordinator {
      XCTAssertTrue(coordinator.persistentStores.count > 0, "Missing persistent store")
    }
  }

  func testInitializationMemoryStore() {
    let optionalCoordinator = NSPersistentStoreCoordinator(automigrating: true)
    XCTAssertNotNil(optionalCoordinator, "Missing coordinator")

    if let coordinator = optionalCoordinator {
      XCTAssertTrue(coordinator.persistentStores.count > 0, "Missing persistent store")
    }
  }
}
