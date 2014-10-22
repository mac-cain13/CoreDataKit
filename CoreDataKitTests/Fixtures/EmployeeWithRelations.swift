//
//  EmployeeWithRelations.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 20-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData
import CoreDataKit

class EmployeeWithRelations: NSManagedObject, NamedManagedObject {

    @NSManaged var name: String
    @NSManaged var age: NSNumber
    @NSManaged var cars: NSMutableSet

    class var entityName: String { return "EmployeeWithRelations" }
}
