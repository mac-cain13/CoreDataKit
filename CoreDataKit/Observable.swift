//
//  Observable.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 31-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

public protocol Subscription {
    func completed()
    func error(error: NSError)
    func next(observable: NSObject)
}

public class Observable<T:NSManagedObject>: NSFetchedResultsControllerDelegate {
    public typealias ChangeHandler = T -> Void

    let observedObject: T
    let fetchedResultsController: NSFetchedResultsController
    var subscriptions: [Subscription]

    public init(observedObject: T, inContext context: NSManagedObjectContext) {
        self.observedObject = observedObject
        self.subscriptions = [Subscription]()

        let predicate = NSPredicate(format: "self.objectID = %@", argumentArray: [self.observedObject.objectID])
        let sortDescriptors = [NSSortDescriptor(key: "self.objectID", ascending: true)]
        let fetchRequest = context.createFetchRequest(self.observedObject.entity, predicate: predicate, sortDescriptors: sortDescriptors)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
    }

    private func performFetch() {
        var optionalError: NSError?
        fetchedResultsController.performFetch(&optionalError)
        if let error = optionalError {
            for subscriber in subscriptions {
                subscriber.error(error)
            }
        }
    }

    public func subscribe(subscriber: Subscription) {
        subscriptions.append(subscriber)

        if subscriptions.count == 1 {
            performFetch()
        }
    }

    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        for subscriber in subscriptions {
            subscriber.next(observedObject)
        }
    }

    deinit {
        for subscriber in subscriptions {
            subscriber.completed()
        }
    }
}
