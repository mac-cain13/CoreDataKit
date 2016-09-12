//
//  NSManagedObject+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 14-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSManagedObject
{
  /**
  Import a dictionary into this managed object

  - parameter dictionary: The dictionary to import

  - returns: Result wheter the import was performed
  */
  public func importDictionary(_ dictionary: [String: AnyObject]) throws {
    if shouldImport(dictionary: dictionary) {
      let transformedDictionary = willImport(dictionary: dictionary)
      do {
        try performImport(dictionary: transformedDictionary)
        didImport(dictionary: transformedDictionary, error: nil)
      }
      catch let err {
        didImport(dictionary: transformedDictionary, error: err)
        throw err
      }

      return
    }

    let entityName = self.entity.name ?? "nil"
    let error = CoreDataKitError.importCancelled(entityName: entityName)
    throw error
  }

  // MARK: Steps in the import process

  /**
  Will be called before import to determine wheter this dictionary should be imported into this object or not

  :discusion: Default implementation just returns true

  - parameter dictionary: The dictionary that will be imported

  :return: Wheter to import or not
  */
  open func shouldImport(dictionary: [String: AnyObject]) -> Bool {
    return true
  }

  @available(*, unavailable, renamed: "shouldImport(dictionary:)")
  public func shouldImport(_ dictionary: [String: AnyObject]) -> Bool {
    fatalError()
  }

  /**
  Will be called right before import gives the chance to change the imported dictionary

  :discusion: Default implementation just returns the given dictionary

  - parameter dictionary: The dictionary that is given to the import method

  :return: The dictionary that will be used in the rest of the import process
  */
  open func willImport(dictionary: [String: AnyObject]) -> [String: AnyObject] {
    return dictionary
  }

  @available(*, unavailable, renamed: "willImport(dictionary:)")
  open func willImport(_ dictionary: [String: AnyObject]) -> [String: AnyObject] {
    fatalError()
  }

  /**
  Performs the import process

  - parameter dictionary: The dictionary to import

  - returns: Result wheter the import succeeded
  */
  fileprivate func performImport(dictionary: [String : AnyObject]) throws {
    if let context = managedObjectContext {
      for propertyDescription in entity.properties {

        switch propertyDescription {
        case let attributeDescription as NSAttributeDescription:
          try performImportAttribute(attributeDescription, dictionary: dictionary)

        case let relationshipDescription as NSRelationshipDescription:
          try performImportRelationship(context, relationship: relationshipDescription, dictionary: dictionary)

        case is NSFetchedPropertyDescription:
          let error = CoreDataKitError.importError(description: "Importing NSFetchedPropertyDescription is not supported")
          throw error

        default:
          let error = CoreDataKitError.importError(description: "Importing unknown subclass or no subclass of NSPropertyDescription is not supported")
          throw error
        }
      }
    } else {
      let error = CoreDataKitError.importError(description: "Managed object not inserted in context, objects must be inserted before importing")
      throw error
    }
  }

  /**
  Called after import is performed

  - parameter dictionary: The dictionary that was imported, this is the dictionary returned by willImport
  - parameter error: Optional error if import failed
  */
  open func didImport(dictionary: [String : AnyObject], error: Error?) {
    // No-op
  }

  @available(*, unavailable, renamed: "didImport(dictionary:)")
  open func didImport(_ dictionary: [String : AnyObject], error: Error?) {
    fatalError()
  }

  // MARK: Import helpers

  /**
  Performs the import of one attribute

  - parameter attribute: The attribute to perform the import on
  - parameter dictionary: The dictionary to import from

  - returns: Result wheter import succeeded
  */
  fileprivate func performImportAttribute(_ attribute: NSAttributeDescription, dictionary: [String: AnyObject]) throws {
    switch attribute.preferredValueFromDictionary(dictionary) {
    case let .some(value):
      if let transformedValue: AnyObject = attribute.transform(value: value) {
        setValue(transformedValue, forKeyPath: attribute.name)
      } else {
        let error = CoreDataKitError.importError(description: "Value '\(value)' could not be transformed to a value compatible with the type of \(entity.name).\(attribute.name)")
        throw error
      }

    case .null:
      setValue(nil, forKeyPath: attribute.name) // We just set it to nil, maybe there is a default value in the model

    case .none:
      // Not found in dictionary, do not change value
      break;
    }
  }

  /**
  Performs the import of one attribute

  - parameter relationship: The relationship to perform the import on
  - parameter dictionary: The dictionary to import from

  - returns: Result wheter import succeeded
  */
  fileprivate func performImportRelationship(_ context: NSManagedObjectContext, relationship: NSRelationshipDescription, dictionary: [String : AnyObject]) throws {
    if let destinationEntity = relationship.destinationEntity {
      let importableValue = relationship.preferredValueFromDictionary(dictionary)

      switch relationship.relationType {
      case .Reference:
        try performImportReferenceRelationship(context, relationship: relationship, importableValue: importableValue, destinationEntity: destinationEntity)

      case .Embedding:
        try performImportEmbeddingRelationship(context, relationship: relationship, importableValue: importableValue, destinationEntity: destinationEntity)
      }
    } else {
      let error = CoreDataKitError.importError(description: "Relationship \(self.entity.name).\(relationship.name) has no destination entity defined")
      throw error
    }
  }

  fileprivate func performImportReferenceRelationship(_ context: NSManagedObjectContext, relationship: NSRelationshipDescription, importableValue: ImportableValue, destinationEntity: NSEntityDescription) throws {
    switch importableValue {
    case let .some(value as [String: AnyObject]):
      let object = try context.importEntity(destinationEntity, dictionary: value)
      try self.updateRelationship(context, relationship: relationship, withValue: object, deleteCurrent: false)

    case .some(_ as [AnyObject]):
      let error = CoreDataKitError.unimplementedMethod(description: "Multiple referenced / nested relationships not yet supported with relation type \(RelationType.Reference)")
      throw error

    case let .some(value):
      let object = try context.findEntityByIdentifyingAttribute(destinationEntity, identifyingValue: value)
      try self.updateRelationship(context, relationship: relationship, withValue: object, deleteCurrent: false)

    case .null:
      return try updateRelationship(context, relationship: relationship, withValue: nil, deleteCurrent: false)

    case .none:
      return // Not found in dictionary, do not change value
    }
  }

  fileprivate func performImportEmbeddingRelationship(_ context: NSManagedObjectContext, relationship: NSRelationshipDescription, importableValue: ImportableValue, destinationEntity: NSEntityDescription) throws {
    switch importableValue {
    case let .some(value as [String: AnyObject]):
      let destinationObject = try context.create(destinationEntity)
      try destinationObject.importDictionary(value)
      try self.updateRelationship(context, relationship: relationship, withValue: destinationObject, deleteCurrent: true)

    case .some(_ as [AnyObject]):
      let error = CoreDataKitError.unimplementedMethod(description: "Multiple nested relationships not yet supported with relation type \(RelationType.Embedding)")
      throw error

    case .some(_):
      let error = CoreDataKitError.unimplementedMethod(description: "Referenced relationships are not supported with relation type \(RelationType.Embedding)")
      throw error

    case .null:
      try self.updateRelationship(context, relationship: relationship, withValue: nil, deleteCurrent: true)

    case .none:
      return // Not found in dictionary, do not change value
    }
  }

  /**
  Helper to update relationship value, adds or sets the relation to the given value or on nil value clears/deletes the whole relation

  - parameter value: The value to update the relationship with
  - parameter relationship: The relationship to update

  :return: Wheter the update succeeded
  */
  fileprivate func updateRelationship(_ context: NSManagedObjectContext, relationship: NSRelationshipDescription, withValue _value: NSManagedObject?, deleteCurrent: Bool) throws {
    if (relationship.isToMany) {
      if let objectSet = value(forKeyPath: relationship.name) as? NSMutableSet {
        if (deleteCurrent) {
          for object in objectSet {
            if let managedObject = object as? NSManagedObject {
              do {
                try context.deleteWithPermanentID(managedObject)
              }
              catch {
              }
            }
          }
        }

        if let object = _value {
          objectSet.add(object)
        } else {
          objectSet.removeAllObjects()
        }
      } else {
        let error = CoreDataKitError.importError(description: "Can't append imported object to to-many relation '\(entity.name).\(relationship.name)' because it's not a NSMutableSet")
        throw error
      }
    } else {
      if (deleteCurrent) {
        if let currentRelatedObject = self.value(forKeyPath: relationship.name) as? NSManagedObject {
          do {
            try context.deleteWithPermanentID(currentRelatedObject)
          }
          catch {
          }
        }
      }

      if let value = _value {
        setValue(value, forKeyPath: relationship.name)
      } else if (relationship.isOptional) {
        setValue(nil, forKeyPath: relationship.name)
      } else {
        let error = CoreDataKitError.importError(description: "Relationship \(self.entity.name).\(relationship.name) is not optional, cannot set to null")
        throw error
      }
    }
  }
}
