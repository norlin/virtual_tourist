//
//  PhotosFetchedResultsDelegate.swift
//  VirtualTourist
//
//  Created by norlin on 13/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import UIKit
import CoreData

extension PhotosViewController: NSFetchedResultsControllerDelegate {
    // core data methods
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
        
            if let _ = anObject as? Photo {
                switch type {
                case .Insert:
                    insertedItems.append(newIndexPath!)
                case .Delete:
                    deletedItems.append(indexPath!)
                default:
                    break
                }
                return
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        dispatch_async(dispatch_get_main_queue()){
            self.photosView.performBatchUpdates({
                if (self.deletedItems.count > 0) {
                    self.photosView.deleteItemsAtIndexPaths(self.deletedItems)
                    self.deletedItems.removeAll()
                    self.deleteLabel.hidden = true
                }
                
                if (self.insertedItems.count > 0) {
                    self.photosView.insertItemsAtIndexPaths(self.insertedItems)
                    self.insertedItems.removeAll()
                }
                
                if (self.fetchedResultsController.fetchedObjects?.count > 0) {
                    self.noPhotosHint.hidden = true
                } else if self.loadintHint.hidden {
                        self.noPhotosHint.hidden = false
                }
            }){done in}
        }
        
        
    }
}
