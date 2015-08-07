//
//  NSFetchedResultsControllerDelegate.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 29-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import UIKit
import CoreData

/**
Simple implementation of NSFetchedResultsControllerDelegate for use with a UITableView

:discussion: Be aware that the NSFetchedResultsController will not retain your delegate object. So you have to keep a reference to this object somewhere.
*/
public class TableViewFetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    var sectionAnimation: UITableViewRowAnimation = .Automatic
    var rowAnimation: UITableViewRowAnimation = .Automatic

    weak var tableView: UITableView?

    /**
    Initialize a delegate
    
    - parameter tableView: The table view to perform the changed the NSFetchedResultsController reports on
    */
    public init(tableView: UITableView) {
        self.tableView = tableView
    }

    /// Implementation of NSFetchedResultsControllerDelegate
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView?.beginUpdates()
    }

    /// Implementation of NSFetchedResultsControllerDelegate
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView?.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: sectionAnimation)

        case .Delete:
            tableView?.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: sectionAnimation)

        default:
            break // Noop
        }
    }

    /// Implementation of NSFetchedResultsControllerDelegate
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: rowAnimation)

        case .Delete:
            tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: rowAnimation)

        case .Move:
            tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: rowAnimation)
            tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: rowAnimation)

        case .Update:
            tableView?.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: rowAnimation)
        }
    }

    /// Implementation of NSFetchedResultsControllerDelegate
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView?.endUpdates()
    }
}
