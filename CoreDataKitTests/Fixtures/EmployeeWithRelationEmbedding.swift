//
//  EmployeeWithRelationEmbedding.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 28-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData
import CoreDataKit

class EmployeeWithRelationEmbedding: NSManagedObject, NamedManagedObject {

  @NSManaged var name: String
  @NSManaged var salary: Salary

  class var entityName: String { return "EmployeeWithRelationEmbedding" }
}
