//
//  EmployeeIncorrectEntityName.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData
import CoreDataKit

class EmployeeIncorrectEntityName: NSManagedObject, NamedManagedObject {

  @NSManaged var name: String

  class var entityName: String { return "EmployeeIncorrectEntityName" }
}
