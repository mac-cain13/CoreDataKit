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

    func testImportWithRelations() {
        if let jsonObject = loadJSONFile("EmployeesWithRelations")? as? [String: AnyObject] {
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
            XCTFail("Missing EmployeesWithRelations.json fixture")
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
