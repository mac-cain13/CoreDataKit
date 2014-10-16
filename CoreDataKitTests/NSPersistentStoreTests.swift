//
//  NSPersistentStoreTests.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import XCTest
import CoreData
import CoreDataKit

class NSPersistentStoreTests: TestCase {
    func testURLForSQLiteStoreName() {
        XCTAssertNotNil(NSPersistentStore.URLForSQLiteStoreName("SuitsStore"), "Store URL missing")
    }
}
