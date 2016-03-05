//
//  DraggableAnnotation.swift
//  Virtual Tourist
//
//  Created by Andrew Fruth on 2/28/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import MapKit

// total credit for this class and idea goes to https://discussions.udacity.com/t/how-can-i-make-a-new-pin-draggable-right-after-adding-it/26653/16 much of code is copied

class DraggableAnnotation: NSObject, MKAnnotation {
    
    private var location = CLLocationCoordinate2D()
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return location
        }
        set(newCoordinate) {
           location = newCoordinate
        }
    }
    
    func setCoordinates(newCoordinate: CLLocationCoordinate2D) {
        willChangeValueForKey("coordinate")
        location = newCoordinate
        didChangeValueForKey("coordinate")
    }
    
}