//
//  NSPropertyDescription.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

let MappingUserInfoKey = "CDKMap"
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

    /// Looks at the available mappings and takes the preferred value out of the given dictionary based on those mappings
    func preferredValueFromDictionary(dictionary: [String: AnyObject]) -> AnyObject? {
        for keyPath in mappings {
            if let value: AnyObject = (dictionary as NSDictionary).valueForKeyPath(keyPath) {
                return value
            }
        }

        return nil
    }
}
