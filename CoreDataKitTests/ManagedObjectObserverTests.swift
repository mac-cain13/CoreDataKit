//
//  ManagedObjectObserverTests.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 01-11-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import CoreDataKit

class ManagedObjectObserverTests: TestCase {
//    func testSubscribersCalled() {
//        let calledExpectation = expectationWithDescription("Subscriber not called")
//
//        var observer: ManagedObjectObserver<Employee>?
//        var observable: Employee!
//
//        coreDataStack.performBlockOnBackgroundContext({ context in
//            observable = context.create(Employee.self).value()
//            observable.name = "Scottie"
//
//            return .SaveToPersistentStore
//        }, completionHandler: { _ in
//            observable = self.coreDataStack.mainThreadContext.find(observable).value()
//
//            observer = ManagedObjectObserver(observeObject: observable as Employee, inContext: self.coreDataStack.mainThreadContext)
//            observer?.subscribe { observedAction in
//                XCTAssertEqual(observedAction.value()!.name, "Dana J. Scott", "Unexpected name")
//                calledExpectation.fulfill()
//            }
//
//            self.coreDataStack.performBlockOnBackgroundContext { context in
//                observable.name = "Dana J. Scott"
//                return .SaveToPersistentStore
//            }
//        })
//
//        waitForExpectationsWithTimeout(3, handler: nil)
//    }

//    func testSubscribersCalledWithObjectOnRootContext() {
//        let calledExpectation = expectationWithDescription("Subscriber not called")
//
//        var observer: ManagedObjectObserver<Employee>?
//        var observable: Employee!
//
//        coreDataStack.performBlockOnBackgroundContext({ context in
//            observable = context.create(Employee.self).value()
//            observable.name = "Scottie"
//
//            return .SaveToPersistentStore
//            }, completionHandler: { _ in
//                observable = self.coreDataStack.rootContext.find(observable).value()
//
//                observer = ManagedObjectObserver(observeObject: observable as Employee, inContext: self.coreDataStack.mainThreadContext)
//                observer?.subscribe { object in
//                    XCTAssertEqual(object.value()!.name, "Dana J. Scott", "Unexpected name")
//                    calledExpectation.fulfill()
//                }
//
//                self.coreDataStack.performBlockOnBackgroundContext { context in
//                    observable.name = "Dana J. Scott"
//                    return .SaveToPersistentStore
//                }
//        })
//        
//        waitForExpectationsWithTimeout(3, handler: nil)
//    }

//    func testNoSubscribers() {
//        let calledExpectation = expectationWithDescription("Subscriber not called")
//
//        var observable: Employee!
//
//        coreDataStack.performBlockOnBackgroundContext({ context in
//            observable = context.create(Employee.self).value()
//            observable.name = "Scottie"
//
//            return .SaveToPersistentStore
//        }, completionHandler: { _ in
//            observable = self.coreDataStack.mainThreadContext.find(observable).value()
//
//            let observer = ManagedObjectObserver(observeObject: observable as Employee, inContext: self.coreDataStack.mainThreadContext)
//
//            self.coreDataStack.performBlockOnBackgroundContext({ context in
//                observable.name = "Dana J. Scott"
//                return .SaveToPersistentStore
//            }, completionHandler: { _ in
//                calledExpectation.fulfill()
//            })
//        })
//
//        waitForExpectationsWithTimeout(3, handler: nil)
//    }

//    func testUnsubscribe() {
//        let calledExpectation = expectationWithDescription("Subscriber not called")
//
//        var observable: Employee!
//
//        coreDataStack.performBlockOnBackgroundContext({ context in
//            observable = context.create(Employee.self).value()
//            observable.name = "Scottie"
//
//            return .SaveToPersistentStore
//            }, completionHandler: { _ in
//                observable = self.coreDataStack.mainThreadContext.find(observable).value()
//
//                let observer = ManagedObjectObserver(observeObject: observable as Employee, inContext: self.coreDataStack.mainThreadContext)
//                let token = observer.subscribe { object in
//                    XCTFail("Unsubscribed subscriber called")
//                }
//                observer.unsubscribe(token)
//
//                self.coreDataStack.performBlockOnBackgroundContext({ context in
//                    observable.name = "Dana J. Scott"
//                    return .SaveToPersistentStore
//                }, completionHandler: { _ in
//                    calledExpectation.fulfill()
//                })
//        })
//        
//        waitForExpectationsWithTimeout(3, handler: nil)
//    }
}
