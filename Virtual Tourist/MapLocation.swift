//
//  MapLocation.swift
//  Virtual Tourist
//
//  Created by Andrew Fruth on 2/10/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapLocation : NSManagedObject {
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var latitudeDelta: NSNumber
    @NSManaged var longitudeDelta: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(region: MKCoordinateRegion, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("MapLocation", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        let coordinates = region.center
        latitude = coordinates.latitude
        longitude = coordinates.longitude
        
        let deltas = region.span
        latitudeDelta = deltas.latitudeDelta
        longitudeDelta = deltas.longitudeDelta

    }
    
    func generateMKCoordinateRegion() -> MKCoordinateRegion {
        
        let castLatitude = latitude as CLLocationDegrees
        let castLongitude = longitude as CLLocationDegrees
        let castLatitudeDelta = latitudeDelta as CLLocationDegrees
        let castLongitudeDelta = longitudeDelta as CLLocationDegrees
        
        let center = CLLocationCoordinate2D(latitude: castLatitude, longitude: castLongitude)
        let span = MKCoordinateSpan(latitudeDelta: castLatitudeDelta, longitudeDelta: castLongitudeDelta)
        return MKCoordinateRegion(center: center, span: span)
        
    }

    
}