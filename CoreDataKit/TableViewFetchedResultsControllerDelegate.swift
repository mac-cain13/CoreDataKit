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
open class TableViewFetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
  var sectionAnimation: UITableViewRowAnimation = .automatic
  var rowAnimation: UITableViewRowAnimation = .automatic

  weak var tableView: UITableView?

  /**
  Initialize a delegate

  - parameter tableView: The table view to perform the changed the NSFetchedResultsController reports on
  */
  public init(tableView: UITableView) {
    self.tableView = tableView
  }

  /// Implementation of NSFetchedResultsControllerDelegate
  open func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView?.beginUpdates()
  }

  /// Implementation of NSFetchedResultsControllerDelegate
  open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      tableView?.insertSections(IndexSet(integer: sectionIndex), with: sectionAnimation)

    case .delete:
      tableView?.deleteSections(IndexSet(integer: sectionIndex), with: sectionAnimation)

    default:
      break // Noop
    }
  }

  /// Implementation of NSFetchedResultsControllerDelegate
  open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      tableView?.insertRows(at: [newIndexPath!], with: rowAnimation)

    case .delete:
      tableView?.deleteRows(at: [indexPath!], with: rowAnimation)

    case .move:
      tableView?.deleteRows(at: [indexPath!], with: rowAnimation)
      tableView?.insertRows(at: [newIndexPath!], with: rowAnimation)

    case .update:
      tableView?.reloadRows(at: [indexPath!], with: rowAnimation)
    }
  }

  /// Implementation of NSFetchedResultsControllerDelegate
  open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView?.endUpdates()
  }
}
