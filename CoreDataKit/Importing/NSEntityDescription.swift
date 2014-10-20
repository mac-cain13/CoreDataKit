//
//  NSEntityDescription.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 16-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

let IdentifierUserInfoKey = "CDKId"

extension NSEntityDescription
{
    var identifyingAttribute: NSAttributeDescription? {
        if let identifyingAttribute = userInfo?[IdentifierUserInfoKey] as? String {
            return self.attributesByName[identifyingAttribute] as? NSAttributeDescription
        } else if let superEntity = self.superentity {
            println("[CoreDataKit] Info: \(IdentifierUserInfoKey) not found on \(self), looking up on super entity...")
            return superEntity.identifyingAttribute
        }

        println("[CoreDataKit] Warning: \(IdentifierUserInfoKey) not found on \(self)")
        return nil
    }
}
