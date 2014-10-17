//
//  NamedManagedObject.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

public protocol NamedManagedObject {
    class var entityName: String { get }
}
