//
//  TravelLocationsViewController.swift
//  Virtual Tourist
//
//  Created by Andrew Fruth on 2/10/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class TravelLocationsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        saveMapRegion()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveMapCoordinates()
    }
    
    lazy var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    func saveMapCoordinates() {
        _ = MapLocation(region: mapView.region, context: sharedContext)
    }
    
    private func saveMapRegion() {
        
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("MapLocation", inManagedObjectContext: sharedContext)
        fetchRequest.entity = entityDescription
        
        do {
            
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            if (results.count > 0) {
                let location = results[0] as! MapLocation
                
                mapView.region = location.generateMKCoordinateRegion()
                deleteOldMapLocations(results)
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
    }
    
    private func deleteOldMapLocations(results: [AnyObject]) {
        for r in results {
            let entry = r as! NSManagedObject
            sharedContext.deleteObject(entry)
            
            do {
                try sharedContext.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }


}

