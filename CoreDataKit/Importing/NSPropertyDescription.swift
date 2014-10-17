//
//  NSPropertyDescription.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

let MappingUserInfoKey = "CDKMapping"
let MaxNumberedMappings = 10

extension NSPropertyDescription
{
    /// Possible dictionary keys that could contain data for this property
    var mappings: [String] {
        var _mappings = [String]()

        // Fetch the unnumbered mapping
        if let unnumberedMapping = userInfo?[MappingUserInfoKey] as? String {
            _mappings.append(unnumberedMapping)
        }

        // Fetch the numbered mappings
        for i in 0...MaxNumberedMappings+1 {
            if let numberedMapping = userInfo?[MappingUserInfoKey + ".\(i)"] as? String {
                _mappings.append(numberedMapping)

                if i == MaxNumberedMappings+1 {
                    println("[CoreDataKit] Warning: Only mappings up to \(MappingUserInfoKey).\(MaxNumberedMappings) mappings are supported, you defined more for \(entity.name).\(name).")
                }
            }
        }

        // Fallback to the name of the property as a mapping if no mappings are defined
        if 0 == _mappings.count {
            _mappings.append(name)
        }

        return _mappings
    }

    func preferredValueFromDictionary(dictionary: [String: AnyObject]) -> AnyObject? {
        for key in mappings {
            if let value: AnyObject = dictionary[key] {
                return value
            }
        }

        return nil
    }
}
