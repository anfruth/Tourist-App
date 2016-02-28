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
    
        let fetchRequest = CoreDataLookup.setupFetchRequest("Pin", context: context)
        
        let latitude = coordinates.latitude as NSNumber
        let longitude = coordinates.longitude as NSNumber
        let latPredicate = NSPredicate(format: "latitude == %@", latitude)
        let longPredicate = NSPredicate(format: "longitude == %@", longitude)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [latPredicate, longPredicate])
        fetchRequest.predicate = predicate
        
        let pinObject = CoreDataLookup.executeFetchRequest(context, fetchRequest: fetchRequest)
        
        return pinObject![0] as! Pin // here is the relevant pin
    }
    
    static func retrievePinPhotos(sharedContext: NSManagedObjectContext) -> AnyObject? {
        
        let fetchRequest = CoreDataLookup.setupFetchRequest("Photo", context: sharedContext)
        
        let predicate = NSPredicate(format: "pin == %@", PhotosCollectionViewController.pinTapped!)
        fetchRequest.predicate = predicate
        
        let photoObject = CoreDataLookup.executeFetchRequest(sharedContext, fetchRequest: fetchRequest)
        return photoObject
    }
    
    static func setupFetchRequest(entityString: String, context: NSManagedObjectContext) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName(entityString, inManagedObjectContext: context)
        fetchRequest.entity = entityDescription
        return fetchRequest
    }
    
    static func executeFetchRequest(context: NSManagedObjectContext, fetchRequest: NSFetchRequest) -> AnyObject? {
        var object: AnyObject? = nil
        do {
            object = try context.executeFetchRequest(fetchRequest)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return nil
        }
        return object

    }
    
}
