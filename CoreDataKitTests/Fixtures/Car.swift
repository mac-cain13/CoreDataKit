//
//  Car.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 20-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

class Car: NSManagedObject {

    @NSManaged var plate: String
    @NSManaged var color: String
    @NSManaged var owners: NSSet

}
