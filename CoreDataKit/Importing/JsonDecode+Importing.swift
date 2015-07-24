//
//  JsonDecode+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-10-14.
//  Copyright (c) 2014 Tom Lokhorst & Mathijs Kadijk. All rights reserved.
//

import Foundation

// We use the decode functions from the JsonDecode+Importing.swift file
extension String {
    static func decode(json : AnyObject) -> String? {
        return json as? String
    }
}

extension Bool {
    static func decode(json : AnyObject) -> Bool? {
        return json as? Bool
    }
}

extension Int {
    static func decode(json : AnyObject) -> Int? {
        return json as? Int
    }
}

extension Int64 {
    static func decode(json : AnyObject) -> Int64? {
        let number = json as? NSNumber
        return number.map { $0.longLongValue }
    }
}

extension Double {
    static func decode(json : AnyObject) -> Double? {
        return json as? Double
    }
}

extension NSData {
    class func decode(json: AnyObject) -> NSData? {
        return json as? NSData
    }
}

extension NSDate {
    struct DateFormatter {
        static let withTimeZone : NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

            return formatter
            }()
    }

    class func decode(json : AnyObject) -> NSDate? {
        if let date = json as? NSDate {
            return date
        } else if let dateString = json as? String {
            return DateFormatter.withTimeZone.dateFromString(dateString)
        }

        return nil
    }
}
