//
//  NSAttributeDescription.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSAttributeDescription
{
    override func preferredValueFromDictionary(dictionary: [String: AnyObject]) -> AnyObject? {
        if let value: AnyObject = super.preferredValueFromDictionary(dictionary) {
            if value is NSNull {
                return nil
            }

            switch (attributeType) {
            case .Integer16AttributeType:
                fallthrough
            case .Integer32AttributeType:
                return Int.decode(value)

            case .Integer64AttributeType:
                if let int64 = Int64.decode(value) {
                    return NSNumber(longLong: int64)
                } else {
                    return nil
                }

            case .DecimalAttributeType:
                fallthrough
            case .DoubleAttributeType:
                fallthrough
            case .FloatAttributeType:
                return Double.decode(value)

            case .StringAttributeType:
                return String.decode(value)

            case .BooleanAttributeType:
                return Bool.decode(value)

            case .DateAttributeType:
                return NSDate.decode(value)

            case .BinaryDataAttributeType:
                return NSData.decode(value)

            case .UndefinedAttributeType:
                fallthrough
            case .TransformableAttributeType:
                fallthrough
            case .ObjectIDAttributeType:
                return nil
            }
        }

        return nil
    }
}
