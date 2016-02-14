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
        retrieveMapRegion()
        
        // http://stackoverflow.com/questions/29241691/how-do-i-use-uilongpressgesturerecognizer-with-a-uicollectionviewcell-in-swift - Thank you.
        let gestureRec = UILongPressGestureRecognizer(target: self, action: "addPin:")
        gestureRec.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(gestureRec)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveMapRegion()
    }
    
    lazy var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    func addPin(gestureRec: UILongPressGestureRecognizer) {
        // http://www.myswiftjourney.me/2014/10/23/using-mapkit-mkmapview-how-to-create-a-annotation/ thanks for help
        let locationOfTap = gestureRec.locationInView(mapView)
        let coordinates = mapView.convertPoint(locationOfTap, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        mapView.addAnnotation(annotation)
    }
    
    private func saveMapRegion() {
        _ = MapLocation(region: mapView.region, context: sharedContext)
    }
    
    private func retrieveMapRegion() {
        
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

