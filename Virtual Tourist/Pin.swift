//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Andrew Fruth on 2/15/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class Pin : NSManagedObject {
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(coordinates: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = coordinates.latitude
        longitude = coordinates.longitude
        
    }
    
    func generateCoordinates() -> MKPointAnnotation {
        
        let castLatitude = latitude as CLLocationDegrees
        let castLongitude = longitude as CLLocationDegrees
        
        let coordinates = CLLocationCoordinate2D(latitude: castLatitude, longitude: castLongitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        return annotation
    }
    
    
}