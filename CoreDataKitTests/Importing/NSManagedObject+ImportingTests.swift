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
                var optionalError: NSError?
                let optionalImportResult = coreDataStack.rootContext.importEntity(EmployeeImportable.self, dictionary: jsonObject, error: &optionalError)
                XCTAssertNil(optionalError, "Unexpected error")
                XCTAssertNotNil(optionalImportResult, "Missing import result")

                if let importResult = optionalImportResult {
                    XCTAssertEqual(importResult.name, jsonObject["checkName"] as String, "Unexpected name")
                    XCTAssertEqual(importResult.age, jsonObject["checkAge"] as Int, "Unexpected age")
                }
            }
        } else {
            XCTFail("Missing Employees.json fixture")
        }
    }

    func testImportDictionaryWithNull() {
        // Prep context with car
        var optionalError: NSError?
        let createdEmployee = coreDataStack.rootContext.create(EmployeeImportable.self, error: &optionalError)
        XCTAssertNil(optionalError, "Unexpected error")
        XCTAssertNotNil(createdEmployee, "Missing employee")

        createdEmployee?.name = "Haircolor Nulled"
        createdEmployee?.age = 100
        createdEmployee?.haircolor = "Yellow"

        if let jsonObject = loadJSONFile("EmployeesWithNull")? as? [String: AnyObject] {
            var optionalError: NSError?
            let optionalImportResult = coreDataStack.rootContext.importEntity(EmployeeImportable.self, dictionary: jsonObject, error: &optionalError)
            XCTAssertNil(optionalError, "Unexpected error")
            XCTAssertNotNil(optionalImportResult, "Missing import result")

            if let importResult = optionalImportResult {
                XCTAssertEqual(importResult.name, "Haircolor Nulled", "Unexpected name")
                XCTAssertEqual(importResult.age, 100, "Unexpected age")
                XCTAssertNil(importResult.haircolor, "Unexpected haircolor")
            }
        } else {
            XCTFail("Missing EmployeesWithNull.json fixture")
        }
    }

    func testImportDictionaryWithOmittedField() {
        // Prep context with car
        var optionalError: NSError?
        let createdEmployee = coreDataStack.rootContext.create(EmployeeImportable.self, error: &optionalError)
        XCTAssertNil(optionalError, "Unexpected error")
        XCTAssertNotNil(createdEmployee, "Missing employee")

        createdEmployee?.name = "Haircolor Omitted"
        createdEmployee?.age = 100
        createdEmployee?.haircolor = "Yellow"

        if let jsonObject = loadJSONFile("EmployeesWithOmittedField")? as? [String: AnyObject] {
            var optionalError: NSError?
            let optionalImportResult = coreDataStack.rootContext.importEntity(EmployeeImportable.self, dictionary: jsonObject, error: &optionalError)
            XCTAssertNil(optionalError, "Unexpected error")
            XCTAssertNotNil(optionalImportResult, "Missing import result")

            if let importResult = optionalImportResult {
                XCTAssertEqual(importResult.name, "Haircolor Omitted", "Unexpected name")
                XCTAssertEqual(importResult.age, 200, "Unexpected age")
                if let haircolor = importResult.haircolor {
                    XCTAssertEqual(importResult.haircolor!, "Yellow", "Unexpected haircolor")
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
            var optionalError: NSError?
            let optionalImportResult = coreDataStack.rootContext.importEntity(EmployeeWithRelations.self, dictionary: jsonObject, error: &optionalError)
            XCTAssertNil(optionalError, "Unexpected error")
            XCTAssertNotNil(optionalImportResult, "Missing import result: \(jsonObject) / \(optionalImportResult) / \(optionalError?)")

            if let importResult = optionalImportResult {
                XCTAssertEqual(importResult.name, "Mike Ross", "Unexpected name")
                XCTAssertEqual(importResult.age, 32, "Unexpected age")
                XCTAssertEqual(importResult.cars.count, 1, "Unexpected count of cars")

                if let car = importResult.cars.anyObject() as? Car {
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
        var optionalError: NSError?
        let createdCar = coreDataStack.rootContext.create(Car.self, error: &optionalError)
        XCTAssertNil(optionalError, "Unexpected error")
        XCTAssertNotNil(createdCar, "Missing car")

        createdCar?.plate = "ZZ-ZZ-ZZ"
        createdCar?.color = "brown"

        if let jsonObject = loadJSONFile("EmployeesReferencedRelation")? as? [String: AnyObject] {
            let optionalImportResult = coreDataStack.rootContext.importEntity(EmployeeWithRelations.self, dictionary: jsonObject, error: &optionalError)
            XCTAssertNil(optionalError, "Unexpected error")
            XCTAssertNotNil(optionalImportResult, "Missing import result: \(jsonObject) / \(optionalImportResult) / \(optionalError?)")

            if let importResult = optionalImportResult {
                XCTAssertEqual(importResult.name, "Mike Ross", "Unexpected name")
                XCTAssertEqual(importResult.age, 23, "Unexpected age")
                XCTAssertEqual(importResult.cars.count, 1, "Unexpected count of cars")

                if let car = importResult.cars.anyObject() as? Car {
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
            var optionalError: NSError?
            let optionalImportResult = coreDataStack.rootContext.importEntity(EmployeeWithRelations.self, dictionary: jsonObject, error: &optionalError)
            XCTAssertNil(optionalError, "Unexpected error")
            XCTAssertNotNil(optionalImportResult, "Missing import result: \(jsonObject) / \(optionalImportResult) / \(optionalError?)")

            if let importResult = optionalImportResult {
                XCTAssertEqual(importResult.name, "Mike Ross", "Unexpected name")
                XCTAssertEqual(importResult.age, 23, "Unexpected age")
                XCTAssertEqual(importResult.cars.count, 0, "Unexpected count of cars")

                if let car = importResult.cars.anyObject() as? Car {
                    XCTAssertEqual(car.plate, "YY-YY-YY", "Unexpected plate")
                    XCTAssertEqual(car.color, "red", "Unexpected color")
                }
            }
        } else {
            XCTFail("Missing EmployeesReferencedRelation.json fixture")
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
