//
//  Pin.swift
//  VirtualTourist
//
//  Created by norlin on 07/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class PinAnnotation: MKPointAnnotation {
    var pin: Pin!
}

@objc(Pin)
class Pin: NSManagedObject {
    @NSManaged var photosDir: String
    @NSManaged var note: Note
    @NSManaged var lat: NSNumber
    @NSManaged var lon: NSNumber
    
    lazy var annotation: PinAnnotation = {
        let coordinate = CLLocationCoordinate2D(latitude: self.lat as Double, longitude: self.lon as Double)
        let annotation = PinAnnotation()
        annotation.coordinate = coordinate
        annotation.pin = self
        return annotation
    }()
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        lat = dictionary["lat"] as! NSNumber
        lon = dictionary["lon"] as! NSNumber
        photosDir = ""
        
        if let note = dictionary["note"] as? [String : AnyObject] {
            self.note = Note(dictionary: note, context: context)
        } else {
            self.note = Note(dictionary: ["text": ""], context: context)
        }
    }
}