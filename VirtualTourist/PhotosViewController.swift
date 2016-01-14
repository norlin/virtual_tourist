//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by norlin on 06/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import UIKit
import CoreData

class PhotosViewController: UIViewController {

    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var photosView: UICollectionView!
    
    @IBOutlet weak var loadintHint: UILabel!
    @IBOutlet weak var noPhotosHint: UILabel!
    
    @IBOutlet weak var deleteLabel: UILabel!
    
    var reloadButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    var insertedItems = [NSIndexPath]()
    var deletedItems = [NSIndexPath]()
    var selectedItems = [NSIndexPath]()
    
    var pin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notes.delegate = self
                
        view.bringSubviewToFront(placeholder)
        view.bringSubviewToFront(deleteLabel)
        view.bringSubviewToFront(noPhotosHint)
        view.bringSubviewToFront(loadintHint)
        
        reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reloadPhotos")
        cancelButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveEditing:")
        
        let tap = UITapGestureRecognizer(target: self, action: "deletePhotos:")
        deleteLabel.addGestureRecognizer(tap)
        
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.rightBarButtonItem = reloadButton
        loadintHint.hidden = true
        noPhotosHint.hidden = false
        deleteLabel.hidden = true
        
        guard pin != nil else {
            self.dismissViewControllerAnimated(animated, completion: nil)
            return
        }
        
        self.sharedContext.performBlockAndWait {
            do {
                try self.fetchedResultsController.performFetch()
            } catch {}
            self.showPinDetails(self.pin!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showPinDetails(pin: Pin) {
        notes.text = pin.note.text
        placeholder.hidden = notes.hasText()
        
        if (pin.photos.count == 0) {
            loadintHint.hidden = false
            noPhotosHint.hidden = true
            self.sharedContext.performBlockAndWait {
                pin.fetchPhotos(){
                    CoreDataStackManager.sharedInstance().saveContext()
                    dispatch_async(dispatch_get_main_queue()) {
                        self.photosView.reloadData()
                        self.noPhotosHint.hidden = true
                        self.loadintHint.hidden = true
                        self.photosView.hidden = false
                    }
                }
            }
        } else {
            photosView.reloadData()
            noPhotosHint.hidden = true
            loadintHint.hidden = true
            photosView.hidden = false
        }
    }

    // photos methods
    func reloadPhotos(){
        guard pin != nil else {
            return
        }
        self.sharedContext.performBlockAndWait {
            for photo in self.pin!.photos {
                self.sharedContext.deleteObject(photo)
            }
        }
        loadintHint.hidden = false
        self.sharedContext.performBlockAndWait {
            self.pin!.fetchPhotos(){
                dispatch_async(dispatch_get_main_queue()){
                    self.loadintHint.hidden = true
                }
                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
    }
    
    func deletePhotos(gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Ended:
            self.sharedContext.performBlockAndWait {
                if self.selectedItems.count > 0 {
                    for item in self.selectedItems {
                        let photo = self.fetchedResultsController.objectAtIndexPath(item) as! NSManagedObject
                        self.sharedContext.deleteObject(photo)
                    }
                    CoreDataStackManager.sharedInstance().saveContext()
                }
            }
        default:
            break
        }
    }
    
        
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        if let pin = self.pin {
            fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        }
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()

}
