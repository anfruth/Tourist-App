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

class TravelLocationsViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveMapRegion()
        retrievePins()
        
        // http://stackoverflow.com/questions/29241691/how-do-i-use-uilongpressgesturerecognizer-with-a-uicollectionviewcell-in-swift - Thank you.
        let gestureRec = UILongPressGestureRecognizer(target: self, action: "addPin:")
        gestureRec.delegate = self
        mapView.addGestureRecognizer(gestureRec)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.hidden = true
        navigationController?.toolbar.hidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveMapRegion()
    }
    
    lazy var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    var annotationToAdd: DraggableAnnotation? = nil
    
    func addPin(gestureRec: UILongPressGestureRecognizer) {
        // much of below code credit goes to this thread: https://discussions.udacity.com/t/how-can-i-make-a-new-pin-draggable-right-after-adding-it/26653/16
        
        // http://www.myswiftjourney.me/2014/10/23/using-mapkit-mkmapview-how-to-create-a-annotation/ thanks for help
        let locationOfTap = gestureRec.locationInView(mapView)
        let coordinates = mapView.convertPoint(locationOfTap, toCoordinateFromView: mapView)
        
        if gestureRec.state == .Began {
            dispatch_async(dispatch_get_main_queue(), {
                self.annotationToAdd = DraggableAnnotation()
                self.annotationToAdd!.setCoordinates(coordinates)
                self.mapView.addAnnotation(self.annotationToAdd!)
            })
        }

        if gestureRec.state == .Changed {
            let currentLocation = gestureRec.locationInView(mapView)
            let coordinates = mapView.convertPoint(currentLocation, toCoordinateFromView: mapView)
            dispatch_async(dispatch_get_main_queue(), {
                self.annotationToAdd!.setCoordinates(coordinates)
            })
        }
        
        if gestureRec.state == .Ended {
            
            // http://www.myswiftjourney.me/2014/10/23/using-mapkit-mkmapview-how-to-create-a-annotation/ thanks for help
            dispatch_async(dispatch_get_main_queue(), {
                self.annotationToAdd!.setCoordinates(coordinates)
            
                let pin = Pin(coordinates: coordinates, context: self.sharedContext)
                CoreDataStackManager.sharedInstance().saveContext()
            
            
                if pin.photos?.count == 0 { // no photos downloaded yet
                    ApiClient.retrievePhotos(coordinates, pin: pin, context: self.sharedContext)
                }
            })
            
        }
    }
    
    
    // Map View Delegate
    
    // reused from On The Map
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let annotation = mapView.selectedAnnotations[0]
        mapView.deselectAnnotation(annotation, animated: true)
        
        let coordinates = (annotation as! DraggableAnnotation).coordinate
        let pin = CoreDataLookup.retrieveClickedPin(coordinates, context: sharedContext)
        
        PhotosCollectionViewController.pinTapped = pin
        self.performSegueWithIdentifier("showPhotos", sender: self)
        
    }
    
    // Private Functions
    
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
    
    private func retrievePins() {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Pin", inManagedObjectContext: sharedContext)
        fetchRequest.entity = entityDescription
        
        do {
            
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            for pinObject in results {
                let annotation = (pinObject as! Pin).generateCoordinates()
                 mapView.addAnnotation(annotation)
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    


}

