//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by norlin on 06/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var editHint: UILabel!
    
    var editMode = false
    let textEdit = "Edit"
    let textDone = "Done"
    
    var newPin: MKPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UILongPressGestureRecognizer(target: self, action: "addPin:")
        tap.minimumPressDuration = 0.3
        map.addGestureRecognizer(tap)
        
        print("start fetch")
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("fetch \(error)")
        }
        print("end fetch")
        
        fetchedResultsController.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        editButton.title = textEdit
        editMode = false
        editHint.hidden = true
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    func clearNewPin(){
        guard let pin = newPin else {
            return
        }
        map.removeAnnotation(pin)
        newPin = nil
    }
    
    func addPin(gestureRecognizer: UIGestureRecognizer) {
        if (editMode) {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(self.map)
        let coordinate = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
        
        switch gestureRecognizer.state {
        case .Began:
            clearNewPin()
            self.newPin = MKPointAnnotation()
            self.newPin!.coordinate = coordinate
            map.addAnnotation(self.newPin!)
        case .Changed:
            self.newPin!.coordinate = coordinate
        case .Cancelled:
            clearNewPin()
        case .Ended:
            clearNewPin()
            let _ = Pin(dictionary: ["lat": coordinate.latitude, "lon": coordinate.longitude], context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
        default:
            break
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        map.deselectAnnotation(view.annotation, animated: false)
        if let annotation = view.annotation as? PinAnnotation {
            if (editMode) {
                let pin = annotation.pin
                sharedContext.deleteObject(pin)
                CoreDataStackManager.sharedInstance().saveContext()
            } else {
                performSegueWithIdentifier("pinDetails", sender: annotation.pin)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "pinDetails") {
            let photosView = segue.destinationViewController as! PhotosViewController
            photosView.pin = sender as? Pin
        }
    }

    @IBAction func editPins(sender: UIBarButtonItem) {
        if (editMode) {
            editButton.title = textEdit
        } else {
            editButton.title = textDone
        }
        
        editHint.hidden = editMode
        editMode = !editMode
    }
    
    // FetchedResults methods

    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            guard let pin = anObject as? Pin else {
                return
            }
            switch type {
            case .Insert:
                map.addAnnotation(pin.annotation)
                
            case .Delete:
                map.removeAnnotation(pin.annotation)
            default:
                break
            }
    }
    
}

