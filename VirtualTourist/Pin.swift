//
//  Pin.swift
//  VirtualTourist
//
//  Created by norlin on 07/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import Foundation
import MapKit

class Pin: MKPointAnnotation {
    let photosDir: String
    var notes: String = ""
    
    override init() {
        self.photosDir = ""
        
        super.init()
    }
    
    func remove() {
        
    }
}