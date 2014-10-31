//
//  Observable.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 31-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

public class ManagedObjectObserver<T:NSManagedObject>: NSFetchedResultsControllerDelegate {
    public typealias ChangeHandler = T -> Void

    public let observedObject: T
    let fetchedResultsController: NSFetchedResultsController
    var subscriptions: [ChangeHandler]

    public init?(observedObject: T, inContext context: NSManagedObjectContext) {
        self.observedObject = observedObject
        self.subscriptions = [ChangeHandler]()

        let predicate = NSPredicate(format: "self = %@", argumentArray: [observedObject.objectID])
        var sortDescriptors: [NSSortDescriptor] = []
        if let anyPropertyName = observedObject.entity.properties.first?.name {
            sortDescriptors = [NSSortDescriptor(key: anyPropertyName, ascending: true)]
        }

        let fetchRequest = context.createFetchRequest(observedObject.entity, predicate: predicate, sortDescriptors: sortDescriptors)
        fetchRequest.returnsObjectsAsFaults = false
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        var optionalError: NSError?
        fetchedResultsController.performFetch(&optionalError)
        if let error = optionalError {
            CoreDataKit.sharedLogger(.ERROR, "Error during fetch for observer: \(error)")
            return nil
        }
    }

    public func subscribe(changeHandler: ChangeHandler) {
        subscriptions.append(changeHandler)
    }

    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        for changeHandler in subscriptions {
            changeHandler(observedObject)
        }
    }
}
