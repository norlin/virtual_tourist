//
//  Photo.swift
//  VirtualTourist
//
//  Created by norlin on 12/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)
class Photo: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var imagePath: String
    @NSManaged var url: String
    @NSManaged var pin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        id = "\(dictionary["id"] as! NSNumber)"
        url = dictionary["image_url"] as! String
        imagePath = "\(pin.id)/\(id)"
    }
    
    func fetchImage(completionHandler: (() -> Void)){
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue) {
            self.sharedContext.performBlockAndWait {
                let imageURL = NSURL(string: self.url)
                if let imageData = NSData(contentsOfURL: imageURL!) {
                    self.image = UIImage(data: imageData)
                } else {
                    print("can't load image!")
                }
                completionHandler()
            }
        }
    }
    
    var image: UIImage? {
        get {
            return PhotosFetcher.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            PhotosFetcher.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath)
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
}