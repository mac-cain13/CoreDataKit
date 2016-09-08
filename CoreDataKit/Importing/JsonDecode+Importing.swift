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
  static func decode(_ json : AnyObject) -> String? {
    return json as? String
  }
}

extension Bool {
  static func decode(_ json : AnyObject) -> Bool? {
    return json as? Bool
  }
}

extension Int {
  static func decode(_ json : AnyObject) -> Int? {
    return json as? Int
  }
}

extension Int64 {
  static func decode(_ json : AnyObject) -> Int64? {
    let number = json as? NSNumber
    return number.map { $0.int64Value }
  }
}

extension Double {
  static func decode(_ json : AnyObject) -> Double? {
    return json as? Double
  }
}

extension Data {
  static func decode(_ json: AnyObject) -> Data? {
    return json as? Data
  }
}

extension Date {
  struct DateFormatter {
    static let withTimeZone : Foundation.DateFormatter = {
      let formatter = Foundation.DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      formatter.locale = Locale(identifier: "en_US_POSIX")

      return formatter
      }()
  }

  static func decode(_ json : AnyObject) -> Date? {
    if let date = json as? Date {
      return date
    } else if let dateString = json as? String {
      return DateFormatter.withTimeZone.date(from: dateString)
    }

    return nil
  }
}
