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


var sharedManagedObjectModel: NSManagedObjectModel = {
  return NSManagedObjectModel.mergedModel(from: Bundle.allBundles)!
}()

class TestCase: XCTestCase {

  lazy var sharedStack: CoreDataStack = {
    let stack = self.setupCoreDataStack(model: sharedManagedObjectModel)

    return stack
  }()

  var coreDataStack: CoreDataStack!

  override func setUp() {
    super.setUp()

    // Fetch model
    let managedObjectModel = sharedManagedObjectModel

    // Setup the shared stack
    CDK.sharedStack = sharedStack

    // Setup the stack for this test
    coreDataStack = setupCoreDataStack(model: managedObjectModel)
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  private func setupCoreDataStack(model: NSManagedObjectModel) -> CoreDataStack {
    let persistentCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    try! persistentCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    return CoreDataStack(persistentStoreCoordinator: persistentCoordinator)
  }
}
