//
//  NamedManagedObject.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

/// Protocol that enables CoreDataKit to handle entities based on a
public protocol NamedManagedObject: class {
    /// The name of the entity as it is known in the managed object model
    static var entityName: String { get }
}
