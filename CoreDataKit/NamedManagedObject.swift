//
//  NamedManagedObject.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

/// Protocol that enables CoreDataKit to handle entities based on a

import Foundation

public protocol NamedManagedObject: class {
    /// The name of the entity as it is known in the managed object model
    static var entityName: String { get }
}

extension NamedManagedObject {
    
    static var entityName: String {
        let classString = NSStringFromClass(self)
        // The entity is the last component of dot-separated class name:
        let components = classString.characters.split{ $0 == "." }.map { String($0) }
        assert(components.count > 0, "Failed extract class name from \(classString)")
        return components.last!
    }
    
}
