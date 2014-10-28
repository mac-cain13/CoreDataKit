//
//  Salary.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 28-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

class Salary: NSManagedObject {

    @NSManaged var amount: NSDecimalNumber
    @NSManaged var employee: EmployeeWithRelationWithouId

}
