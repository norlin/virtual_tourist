//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by norlin on 06/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var editHint: UILabel!
    
    var editMode = false
    let textEdit = "Edit"
    let textDone = "Done"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UILongPressGestureRecognizer(target: self, action: "addPin:")
        tap.minimumPressDuration = 0.3
        map.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        editButton.title = textEdit
        editMode = false
        editHint.hidden = true
    }

    // map methods
    func addPin(gestureRecognizer: UIGestureRecognizer) {
        if (editMode) {
            return
        }
        
        if (gestureRecognizer.state != UIGestureRecognizerState.Began) {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(self.map)
        let coordinate = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
        
        let pin = Pin()
        pin.coordinate = coordinate
        
        map.addAnnotation(pin)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        map.deselectAnnotation(view.annotation, animated: false)
        if let pin = view.annotation as? Pin {
            if (editMode) {
                map.removeAnnotation(pin)
                pin.remove()
            } else {
                performSegueWithIdentifier("pinDetails", sender: pin)
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
    
}

