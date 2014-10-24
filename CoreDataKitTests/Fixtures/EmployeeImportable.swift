//
//  EmployeeImportable.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 18-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData
import CoreDataKit

class EmployeeImportable: NSManagedObject, NamedManagedObject {

    @NSManaged var name: String
    @NSManaged var age: Int
    @NSManaged var haircolor: String?

    class var entityName: String { return "EmployeeImportable" }
}
