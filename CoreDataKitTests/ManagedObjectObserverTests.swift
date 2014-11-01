//
//  ManagedObjectObserverTests.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 01-11-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import XCTest
import CoreData
import CoreDataKit

//class ManagedObjectObserverTests: TestCase {
//    var observable: Employee!
//
//    override func setUp() {
//        super.setUp()
//
//        coreDataStack.performBlockOnBackgroundContext({ context in
//            self.observable = context.create(Employee.self).value()
//            self.observable.name = "Scottie"
//
//            return .SaveToPersistentStore
//        }, completionHandler: { _ in
//            self.observable = self.coreDataStack.mainThreadContext.find(self.observable).value()
//        })
//    }
//
//    func testSubscribersCalled() {
//        let calledExpectation = expectationWithDescription("Subscriber not called")
//
//        let observer = ManagedObjectObserver(observedObject: observable as Employee, inContext: coreDataStack.mainThreadContext)
//        observer.subscribe { object in
//            XCTAssertEqual(object.name, "Dana J. Scott", "Unexpected name")
//            calledExpectation.fulfill()
//        }
//
//        coreDataStack.performBlockOnBackgroundContext { context in
//            self.observable.name = "Dana J. Scott"
//            return .SaveToPersistentStore
//        }
//
//        waitForExpectationsWithTimeout(3, handler: nil)
//    }
//
//    func testNoSubscribers() {
//
//    }
//
//    func testUnsubscribe() {
//
//    }
//}
