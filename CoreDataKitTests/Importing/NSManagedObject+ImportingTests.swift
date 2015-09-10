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
    guard let jsonArray = loadJSONFile("Employees") as? [[String: AnyObject]] else {
      XCTFail("Missing Employees.json fixture")
      return
    }

    for jsonObject in jsonArray {
      do {
        let result = try coreDataStack.rootContext.importEntity(EmployeeImportable.self, dictionary: jsonObject)

        XCTAssertEqual(result.name, jsonObject["checkName"] as? String, "Unexpected name")
        XCTAssertEqual(result.age, jsonObject["checkAge"] as? Int, "Unexpected age")
      }
      catch {
        XCTFail("Unexpected error")
      }
    }
  }

  func testImportDictionaryWithNull() {

    guard let jsonObject = loadJSONFile("EmployeesWithNull") as? [String: AnyObject] else {
      XCTFail("Missing EmployeesWithNull.json fixture")
      return
    }

    do {
      let object = try coreDataStack.rootContext.create(EmployeeImportable.self)
      object.name = "Haircolor Nulled"
      object.age = 100
      object.haircolor = "Yellow"

      let imported = try coreDataStack.rootContext.importEntity(EmployeeImportable.self, dictionary: jsonObject)
      XCTAssertEqual(imported.name, "Haircolor Nulled", "Unexpected name")
      XCTAssertEqual(imported.age, 100, "Unexpected age")
      XCTAssertNil(imported.haircolor, "Unexpected haircolor")
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  func testImportDictionaryWithOmittedField() {

    guard let jsonObject = loadJSONFile("EmployeesWithOmittedField") as? [String: AnyObject] else {
      XCTFail("Missing EmployeesWithOmittedField.json fixture")
      return
    }

    do {
      let object = try coreDataStack.rootContext.create(EmployeeImportable.self)
      object.name = "Haircolor Omitted"
      object.age = 100
      object.haircolor = "Yellow"

      let imported = try coreDataStack.rootContext.importEntity(EmployeeImportable.self, dictionary: jsonObject)
      XCTAssertEqual(imported.name, "Haircolor Omitted", "Unexpected name")
      XCTAssertEqual(imported.age, 200, "Unexpected age")
      if let haircolor = imported.haircolor {
        XCTAssertEqual(haircolor, "Yellow", "Unexpected haircolor")
      } else {
        XCTFail("Missing haircolor")
      }
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  func testImportWithNestedRelation() {

    guard let jsonObject = loadJSONFile("EmployeesNestedRelation") as? [String: AnyObject] else {
      XCTFail("Missing EmployeesNestedRelation.json fixture")
      return
    }

    do {
      let imported = try coreDataStack.rootContext.importEntity(EmployeeWithRelations.self, dictionary: jsonObject)
      XCTAssertEqual(imported.name, "Mike Ross", "Unexpected name")
      XCTAssertEqual(imported.age, 32, "Unexpected age")
      XCTAssertEqual(imported.cars.count, 1, "Unexpected count of cars")

      if let car = imported.cars.anyObject() as? Car {
        XCTAssertEqual(car.plate, "YY-YY-YY", "Unexpected plate")
        XCTAssertEqual(car.color, "red", "Unexpected color")
      }
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  func testImportWithExistingReferencedRelation() {

    guard let jsonObject = loadJSONFile("EmployeesReferencedRelation") as? [String: AnyObject] else {
      XCTFail("Missing EmployeesReferencedRelation.json fixture")
      return
    }

    do {
      let object = try coreDataStack.rootContext.create(Car.self)
      object.plate = "ZZ-ZZ-ZZ"
      object.color = "brown"

      let imported = try coreDataStack.rootContext.importEntity(EmployeeWithRelations.self, dictionary: jsonObject)

      XCTAssertEqual(imported.name, "Mike Ross", "Unexpected name")
      XCTAssertEqual(imported.age, 23, "Unexpected age")
      XCTAssertEqual(imported.cars.count, 1, "Unexpected count of cars")

      if let car = imported.cars.anyObject() as? Car {
        XCTAssertEqual(car.plate, "ZZ-ZZ-ZZ", "Unexpected plate")
        XCTAssertEqual(car.color, "brown", "Unexpected color")
      }
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  func testImportWithUnexistingReferencedRelation() {

    guard let jsonObject = loadJSONFile("EmployeesReferencedRelation") as? [String: AnyObject] else {
      XCTFail("Missing EmployeesReferencedRelation.json fixture")
      return
    }

    do {
      let imported = try coreDataStack.rootContext.importEntity(EmployeeWithRelations.self, dictionary: jsonObject)
      XCTAssertEqual(imported.name, "Mike Ross", "Unexpected name")
      XCTAssertEqual(imported.age, 23, "Unexpected age")
      XCTAssertEqual(imported.cars.count, 0, "Unexpected count of cars")

      if let car = imported.cars.anyObject() as? Car {
        XCTAssertEqual(car.plate, "YY-YY-YY", "Unexpected plate")
        XCTAssertEqual(car.color, "red", "Unexpected color")
      }
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  func testImportNestedEmbeddingRelation() {

    guard let jsonObject = loadJSONFile("EmployeesNestedEmbeddingRelation") as? [String: AnyObject] else {
      XCTFail("Missing EmployeesNestedEmbeddingRelation.json fixture")
      return
    }

    do {
      let imported = try coreDataStack.rootContext.importEntity(EmployeeWithRelationEmbedding.self, dictionary: jsonObject)
      XCTAssertEqual(imported.name, "Jessica Pearson", "Unexpected name")
      XCTAssertEqual(imported.salary.amount, 123456789, "Unexpected salary")
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  /// This test covers https://github.com/mac-cain13/CoreDataKit/issues/4
  func testOldValueIsDeletedWhenEmbeddingRelationIsUpdated() {

    guard let jsonObject = loadJSONFile("EmployeesNestedEmbeddingRelation") as? [String: AnyObject] else {
      XCTFail("Missing EmployeesNestedEmbeddingRelation.json fixture")
      return
    }

    do {
      try coreDataStack.rootContext.importEntity(EmployeeWithRelationEmbedding.self, dictionary: jsonObject)
      try coreDataStack.rootContext.importEntity(EmployeeWithRelationEmbedding.self, dictionary: jsonObject)

      let results = try coreDataStack.rootContext.find(Salary.self)
      XCTAssertEqual(results.count, 1, "Unexpected Salary count")
    }
    catch {
      XCTFail("Unexpected error")
    }
  }

  private func loadJSONFile(filename: String) -> AnyObject? {
    for bundle in NSBundle.allBundles() {
      if let fileURL = bundle.URLForResource(filename, withExtension: "json") {
        let data = NSData(contentsOfURL: fileURL)!
        do {
          let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
          return json
        } catch let error as NSError {
          XCTFail("Unexpected error while decoding JSON: \(error)")
        }
      }
    }

    return nil
  }
}
