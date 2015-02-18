//
//  NSManagedObject+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 18-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import XCTest
import CoreData
import CoreDataKit

class NSManagedObjectTests: TestCase {
    func testImportDictionary() {
        if let jsonArray = loadJSONFile("Employees")? as? [[String: AnyObject]] {
            for jsonObject in jsonArray {
                switch coreDataStack.rootContext.importEntity(EmployeeImportable.self, dictionary: jsonObject) {
                case .Failure:
                    XCTFail("Unexpected error")

                case let .Success(boxedImportResult):
                    XCTAssertEqual(boxedImportResult().name, jsonObject["checkName"] as String, "Unexpected name")
                    XCTAssertEqual(boxedImportResult().age, jsonObject["checkAge"] as Int, "Unexpected age")
                }
            }
        } else {
            XCTFail("Missing Employees.json fixture")
        }
    }

    func testImportDictionaryWithNull() {
        // Prep context with employee
        switch coreDataStack.rootContext.create(EmployeeImportable.self) {
        case .Failure:
            XCTFail("Unexpected error")

        case let .Success(boxedObject):
            boxedObject().name = "Haircolor Nulled"
            boxedObject().age = 100
            boxedObject().haircolor = "Yellow"
        }

        if let jsonObject = loadJSONFile("EmployeesWithNull")? as? [String: AnyObject] {
            switch coreDataStack.rootContext.importEntity(EmployeeImportable.self, dictionary: jsonObject) {
            case .Failure:
                XCTFail("Unexpected error")

            case let .Success(boxedImportedObject):
                XCTAssertEqual(boxedImportedObject().name, "Haircolor Nulled", "Unexpected name")
                XCTAssertEqual(boxedImportedObject().age, 100, "Unexpected age")
                XCTAssertNil(boxedImportedObject().haircolor, "Unexpected haircolor")
            }
        } else {
            XCTFail("Missing EmployeesWithNull.json fixture")
        }
    }

    func testImportDictionaryWithOmittedField() {
        // Prep context with employee
        switch coreDataStack.rootContext.create(EmployeeImportable.self) {
        case .Failure:
            XCTFail("Unexpected error")

        case let .Success(boxedObject):
            boxedObject().name = "Haircolor Omitted"
            boxedObject().age = 100
            boxedObject().haircolor = "Yellow"
        }

        if let jsonObject = loadJSONFile("EmployeesWithOmittedField")? as? [String: AnyObject] {
            switch coreDataStack.rootContext.importEntity(EmployeeImportable.self, dictionary: jsonObject) {
            case .Failure:
                XCTFail("Unexpected error")

            case let .Success(boxedImportedObject):
                XCTAssertEqual(boxedImportedObject().name, "Haircolor Omitted", "Unexpected name")
                XCTAssertEqual(boxedImportedObject().age, 200, "Unexpected age")
                if let haircolor = boxedImportedObject().haircolor {
                    XCTAssertEqual(haircolor, "Yellow", "Unexpected haircolor")
                } else {
                    XCTFail("Missing haircolor")
                }
            }
        } else {
            XCTFail("Missing EmployeesWithOmittedField.json fixture")
        }
    }

    func testImportWithNestedRelation() {
        if let jsonObject = loadJSONFile("EmployeesNestedRelation")? as? [String: AnyObject] {
            switch coreDataStack.rootContext.importEntity(EmployeeWithRelations.self, dictionary: jsonObject) {
            case .Failure:
                XCTFail("Unexpected error")

            case let .Success(boxedImportedObject):
                XCTAssertEqual(boxedImportedObject().name, "Mike Ross", "Unexpected name")
                XCTAssertEqual(boxedImportedObject().age, 32, "Unexpected age")
                XCTAssertEqual(boxedImportedObject().cars.count, 1, "Unexpected count of cars")

                if let car = boxedImportedObject().cars.anyObject() as? Car {
                    XCTAssertEqual(car.plate, "YY-YY-YY", "Unexpected plate")
                    XCTAssertEqual(car.color, "red", "Unexpected color")
                }
            }
        } else {
            XCTFail("Missing EmployeesNestedRelation.json fixture")
        }
    }

    func testImportWithExistingReferencedRelation() {
        // Prep context with car
        switch coreDataStack.rootContext.create(Car.self) {
        case .Failure:
            XCTFail("Unexpected error")

        case let .Success(boxedObject):
            boxedObject().plate = "ZZ-ZZ-ZZ"
            boxedObject().color = "brown"
        }

        if let jsonObject = loadJSONFile("EmployeesReferencedRelation")? as? [String: AnyObject] {
            switch coreDataStack.rootContext.importEntity(EmployeeWithRelations.self, dictionary: jsonObject) {
            case .Failure:
                XCTFail("Unexpected error")

            case let .Success(boxedObject):
                XCTAssertEqual(boxedObject().name, "Mike Ross", "Unexpected name")
                XCTAssertEqual(boxedObject().age, 23, "Unexpected age")
                XCTAssertEqual(boxedObject().cars.count, 1, "Unexpected count of cars")

                if let car = boxedObject().cars.anyObject() as? Car {
                    XCTAssertEqual(car.plate, "ZZ-ZZ-ZZ", "Unexpected plate")
                    XCTAssertEqual(car.color, "brown", "Unexpected color")
                }
            }
        } else {
            XCTFail("Missing EmployeesReferencedRelation.json fixture")
        }
    }

    func testImportWithUnexistingReferencedRelation() {
        if let jsonObject = loadJSONFile("EmployeesReferencedRelation")? as? [String: AnyObject] {
            switch coreDataStack.rootContext.importEntity(EmployeeWithRelations.self, dictionary: jsonObject) {
            case .Failure:
                XCTFail("Unexpected error")

            case let .Success(boxedObject):
                XCTAssertEqual(boxedObject().name, "Mike Ross", "Unexpected name")
                XCTAssertEqual(boxedObject().age, 23, "Unexpected age")
                XCTAssertEqual(boxedObject().cars.count, 0, "Unexpected count of cars")

                if let car = boxedObject().cars.anyObject() as? Car {
                    XCTAssertEqual(car.plate, "YY-YY-YY", "Unexpected plate")
                    XCTAssertEqual(car.color, "red", "Unexpected color")
                }
            }
        } else {
            XCTFail("Missing EmployeesReferencedRelation.json fixture")
        }
    }

    func testImportNestedEmbeddingRelation() {
        if let jsonObject = loadJSONFile("EmployeesNestedEmbeddingRelation")? as? [String: AnyObject] {
            switch coreDataStack.rootContext.importEntity(EmployeeWithRelationEmbedding.self, dictionary: jsonObject) {
            case let .Failure(error):
                XCTFail("Unexpected error \(error)")

            case let .Success(boxedObject):
                XCTAssertEqual(boxedObject().name, "Jessica Pearson", "Unexpected name")
                XCTAssertEqual(boxedObject().salary.amount, 123456789, "Unexpected salary")
            }
        } else {
            XCTFail("Missing EmployeesNestedEmbeddingRelation.json fixture")
        }
    }

    /// This test covers https://github.com/mac-cain13/CoreDataKit/issues/4
    func testOldValueIsDeletedWhenEmbeddingRelationIsUpdated() {
        let count = coreDataStack.rootContext.find(Salary.self).value()?.count ?? -1
        XCTAssertEqual(count, 0, "Salary on start incorrect")

        if let jsonObject = loadJSONFile("EmployeesNestedEmbeddingRelation")? as? [String: AnyObject] {
            switch coreDataStack.rootContext.importEntity(EmployeeWithRelationEmbedding.self, dictionary: jsonObject) {
            case let .Failure(error):
                XCTFail("Unexpected error \(error)")

            case let .Success(boxedObject):
                switch coreDataStack.rootContext.importEntity(EmployeeWithRelationEmbedding.self, dictionary: jsonObject) {
                case let .Failure(error):
                    XCTFail("Unexpected error \(error)")

                case let .Success(boxedObject):
                    let count = coreDataStack.rootContext.find(Salary.self).value()?.count ?? -1
                    XCTAssertEqual(count, 1, "Unexpected Salary count")
                }
            }
        } else {
            XCTFail("Missing EmployeesNestedEmbeddingRelation.json fixture")
        }
    }

    private func loadJSONFile(filename: String) -> AnyObject? {
        for bundle in NSBundle.allBundles() {
            if let fileURL = bundle.URLForResource(filename, withExtension: "json") {
                let data = NSData(contentsOfURL: fileURL)!
                var optionalError: NSError?
                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: &optionalError)
                XCTAssertNil(optionalError, "Unexpected error while decoding JSON")
                XCTAssertNotNil(json, "Missing decoded JSON")
                return json
            }
        }

        return nil
    }
}
