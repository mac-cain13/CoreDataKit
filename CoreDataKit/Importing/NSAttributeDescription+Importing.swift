//
//  NSAttributeDescription+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSAttributeDescription
{
  /**
  Transform given value to a value that can be saved into this attribute in CoreData

  - parameter value: The value to transform

  - returns: The transformed value or nil if the value can't for into this attribute
  */
  func transform(value: AnyObject) -> AnyObject? {
    switch attributeType {
    case .integer16AttributeType:
      fallthrough
    case .integer32AttributeType:
      return Int.decode(value) as AnyObject?

    case .integer64AttributeType:
      if let int64 = Int64.decode(value) {
        return NSNumber(value: int64 as Int64)
      } else {
        return nil
      }

    case .decimalAttributeType:
      fallthrough
    case .doubleAttributeType:
      fallthrough
    case .floatAttributeType:
      return Double.decode(value) as AnyObject?

    case .stringAttributeType:
      return String.decode(value) as AnyObject?

    case .booleanAttributeType:
      return Bool.decode(value) as AnyObject?

    case .dateAttributeType:
      return Date.decode(value) as AnyObject?

    case .binaryDataAttributeType:
      return Data.decode(value) as AnyObject?

    case .undefinedAttributeType:
      fallthrough
    case .transformableAttributeType:
      fallthrough
    case .objectIDAttributeType:
      return nil
    }
  }

  @available(*, unavailable, renamed: "transform(value:)")
  func transformValue(_ value: AnyObject) -> AnyObject? {
    fatalError()
  }
}
