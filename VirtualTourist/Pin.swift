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
        print("create pin entity")
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        print("created pin \(self)")
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        lat = dictionary["lat"] as! NSNumber
        lon = dictionary["lon"] as! NSNumber
        photosDir = ""
        
        print("init note")
        if let note = dictionary["note"] as? [String : AnyObject] {
                print("init note 1")
            self.note = Note(dictionary: note, context: context)
                    print("init note 2")
        } else {
                print("init note 3")
            self.note = Note(dictionary: ["text": ""], context: context)
                    print("init note 4")
        }
    }
}