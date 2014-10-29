//
//  NSFetchedResultsControllerDelegate.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 29-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import UIKit
import CoreData

class TableViewFetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate {
    var sectionAnimation: UITableViewRowAnimation = .Fade
    var rowAnimation: UITableViewRowAnimation = .Fade

    let tableView: UITableView

    init(tableView: UITableView) {
        self.tableView = tableView
    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: sectionAnimation)

        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: sectionAnimation)

        default:
            break // Noop
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: rowAnimation)

        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: rowAnimation)

        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: rowAnimation)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: rowAnimation)

        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: rowAnimation)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}
