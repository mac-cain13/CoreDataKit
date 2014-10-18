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
        for bundle in NSBundle.allBundles() {
            if let fileURL = bundle.URLForResource("Employees", withExtension: "json") {
                let data = NSData(contentsOfURL: fileURL)!
                if let jsonArray = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: nil)? as? [[String: AnyObject]] {
                    for jsonObject in jsonArray {
                        var optionalError: NSError?
                        var optionalImportResult = coreDataStack.rootContext.importEntity(EmployeeImportable.self, dictionary: jsonObject, error: &optionalError)
                        XCTAssertNil(optionalError, "Unexpected error")
                        XCTAssertNotNil(optionalImportResult, "Missing import result: \(jsonObject) / \(optionalError?)")

                        if let importResult = optionalImportResult {
                            let check = jsonObject["checkName"] as String
                            XCTAssertEqual(importResult.name, check, "Unexpected name")
                        }
                    }
                }
            }
        }
    }
}
