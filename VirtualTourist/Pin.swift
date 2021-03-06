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
    @NSManaged var id: String
    @NSManaged var note: Note
    @NSManaged var lat: NSNumber
    @NSManaged var lon: NSNumber
    @NSManaged var photos: [Photo]
    @NSManaged var pagesCount: NSNumber
    
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
        
        id = NSUUID().UUIDString
        lat = dictionary["lat"] as! NSNumber
        lon = dictionary["lon"] as! NSNumber
        if let pagesCount = dictionary["pagesCount"] as? NSNumber {
            self.pagesCount = pagesCount
        } else {
            self.pagesCount = 1
        }
        
        if let note = dictionary["note"] as? [String : AnyObject] {
            self.note = Note(dictionary: note, context: context)
        } else {
            self.note = Note(dictionary: ["text": ""], context: context)
        }
    }
    
    func fetchPhotos(completionHandler: () -> Void){
        PhotosFetcher.sharedInstance().searchPhotos(self.lat as Double, lon: self.lon as Double, pagesCount: self.pagesCount as Int){err, photos, pagesCount in
            guard err == nil && photos != nil else {
                return
            }
            self.pagesCount = pagesCount
            for photo in photos! {
                photo.pin = self
            }
            
            completionHandler()
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
}