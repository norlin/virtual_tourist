//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by norlin on 06/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import UIKit
import CoreData

class PhotosViewController: UIViewController, UITextViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var photosView: UICollectionView!
    
    @IBOutlet weak var loadintHint: UILabel!
    @IBOutlet weak var noPhotosHint: UILabel!
    var reloadButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    var pin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notes.delegate = self
        
        reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reloadPhotos")
        cancelButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveEditing:")
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.bringSubviewToFront(placeholder)
        navigationItem.rightBarButtonItem = reloadButton
        loadintHint.hidden = true
        noPhotosHint.hidden = false
        
        guard pin != nil else {
            self.dismissViewControllerAnimated(animated, completion: nil)
            return
        }
        
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
        print("TODO: reloadPhotos")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0 && pin != nil) {
            return pin!.photos.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let CellIdentifier = "PhotoCell"
            
        let photos = pin!.photos
        let photo = photos[indexPath.row]
        
        let cell = photosView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! PhotoCellView
        
        if let image = photo.image {
            cell.image.image = image
        } else {
            photo.fetchImage(){
                dispatch_async(dispatch_get_main_queue()){
                    cell.image.image = photo.image
                }
            }
        }
        
        return cell
    }
    
    // core data methods
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
}
