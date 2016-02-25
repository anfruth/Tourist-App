//
//  CoreDataLookup.swift
//  Virtual Tourist
//
//  Created by Andrew Fruth on 2/24/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import CoreData
import MapKit

struct CoreDataLookup {
    
    static func retrieveClickedPin(coordinates: CLLocationCoordinate2D, context: NSManagedObjectContext) -> Pin {
        
        let latitude = coordinates.latitude as NSNumber
        let longitude = coordinates.longitude as NSNumber
        
        
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)
        fetchRequest.entity = entityDescription
        
        let latPredicate = NSPredicate(format: "latitude == %@", latitude)
        let longPredicate = NSPredicate(format: "longitude == %@", longitude)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [latPredicate, longPredicate])
        
        fetchRequest.predicate = predicate
        var pinObject: AnyObject? = nil
        do {
            pinObject = try context.executeFetchRequest(fetchRequest)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return pinObject![0] as! Pin // here is the relevant pin
        
    }
    
}
