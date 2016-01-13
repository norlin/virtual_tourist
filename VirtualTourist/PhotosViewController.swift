//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by norlin on 06/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import UIKit
import CoreData

class PhotosViewController: UIViewController, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

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
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        showPinDetails(pin!)
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
            pin.fetchPhotos(){
                CoreDataStackManager.sharedInstance().saveContext()
                dispatch_async(dispatch_get_main_queue()) {
                    self.photosView.reloadData()
                    self.noPhotosHint.hidden = true
                    self.loadintHint.hidden = true
                    self.photosView.hidden = false
                }
            }
        } else {
            photosView.reloadData()
            noPhotosHint.hidden = true
            loadintHint.hidden = true
            photosView.hidden = false
        }
    }

    // notes methods
    func textViewDidEndEditing(textView: UITextView) {
        placeholder.hidden = textView.hasText()
    }
    
    func textViewDidChange(textView: UITextView) {
        placeholder.hidden = textView.hasText()
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        navigationItem.rightBarButtonItem = cancelButton
        return true
    }
    
    func saveEditing(textField: UITextField) {
        view.endEditing(true)
        navigationItem.rightBarButtonItem = reloadButton
        guard pin != nil else {
            return
        }
        
        pin!.note.text = notes.text
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // photos methods
    func reloadPhotos(){
        guard pin != nil else {
            return
        }
        for photo in pin!.photos {
            self.sharedContext.deleteObject(photo)
        }
        loadintHint.hidden = false
        pin!.fetchPhotos(){
            dispatch_async(dispatch_get_main_queue()){
                self.loadintHint.hidden = true
            }
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        let count = sectionInfo.numberOfObjects
        
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        let cell = photosView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCellView
        
        if let image = photo.image {
            cell.image.image = image
            cell.loader.hidden = true
        } else {
            cell.image.image = UIImage(named: "Placeholder")
            cell.loader.hidden = false
            cell.loader.startAnimating()
            photo.fetchImage(){
                dispatch_async(dispatch_get_main_queue()){
                    cell.image.image = photo.image
                    cell.loader.stopAnimating()
                    cell.loader.hidden = true
                }
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
        if let index = selectedItems.indexOf(indexPath) {
            selectedItems.removeAtIndex(index)
            let cell = photosView.cellForItemAtIndexPath(indexPath) as! PhotoCellView
            cell.image.alpha = 1
        } else {
            selectedItems.append(indexPath)
            let cell = photosView.cellForItemAtIndexPath(indexPath) as! PhotoCellView
            cell.image.alpha = 0.6
        }
        
        if (selectedItems.count > 0) {
            deleteLabel.hidden = false
        } else {
            deleteLabel.hidden = true
        }
    }
    
    func deletePhotos(gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Ended:
            if selectedItems.count > 0 {
                for item in selectedItems {
                    let photo = fetchedResultsController.objectAtIndexPath(item) as! NSManagedObject
                    sharedContext.deleteObject(photo)
                }
                CoreDataStackManager.sharedInstance().saveContext()
            }
        default:
            break
        }
    }
    
    // core data methods
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
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
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
        
            if let photo = anObject as? Photo {
                switch type {
                case .Insert:
                    insertedItems.append(newIndexPath!)
                    break
                case .Delete:
                    deletedItems.append(indexPath!)
                    PhotosFetcher.Caches.imageCache.storeImage(nil, withIdentifier: photo.imagePath)
                default:
                    break
                }
                return
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        photosView.performBatchUpdates({
            if (self.deletedItems.count > 0) {
                self.photosView.deleteItemsAtIndexPaths(self.deletedItems)
                self.deletedItems.removeAll()
                dispatch_async(dispatch_get_main_queue()){
                    self.deleteLabel.hidden = true
                }
            }
            
            if (self.insertedItems.count > 0) {
                self.photosView.insertItemsAtIndexPaths(self.insertedItems)
                self.insertedItems.removeAll()
            }
            
            if (self.fetchedResultsController.fetchedObjects?.count > 0) {
                dispatch_async(dispatch_get_main_queue()){
                    self.noPhotosHint.hidden = true
                }
            } else if self.loadintHint.hidden {
                dispatch_async(dispatch_get_main_queue()){
                    self.noPhotosHint.hidden = false
                }
            }
        }){done in}
        
        
    }

}
