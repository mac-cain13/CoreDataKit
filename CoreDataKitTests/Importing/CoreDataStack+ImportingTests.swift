//
//  CoreDataStack+ImportingTests.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 05-11-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import XCTest
import CoreData
import CoreDataKit

class CoreDataStackImportingTests: TestCase {
  func testDumpImportConfiguration() {
    coreDataStack.dumpImportConfiguration()
  }
}
