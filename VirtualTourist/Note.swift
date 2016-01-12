//
//  Note.swift
//  VirtualTourist
//
//  Created by norlin on 07/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import Foundation
import CoreData

@objc(Note)
class Note: NSManagedObject {
    @NSManaged var text: String
    @NSManaged var pin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Note", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        text = dictionary["text"] as! String
    }
}