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
        
        // http://stackoverflow.com/questions/29241691/how-do-i-use-uilongpressgesturerecognizer-with-a-uicollectionviewcell-in-swift - Thank you.
        let gestureRec = UILongPressGestureRecognizer(target: self, action: "addPin:")
        gestureRec.delegate = self
        mapView.addGestureRecognizer(gestureRec)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveMapRegion()
    }
    
    lazy var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    func addPin(gestureRec: UILongPressGestureRecognizer) {
        
        if gestureRec.state == .Ended {
            
            // http://www.myswiftjourney.me/2014/10/23/using-mapkit-mkmapview-how-to-create-a-annotation/ thanks for help
            let locationOfTap = gestureRec.locationInView(mapView)
            let coordinates = mapView.convertPoint(locationOfTap, toCoordinateFromView: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            
            let pin = Pin(coordinates: coordinates, context: sharedContext)
            
            do {
                try pin.managedObjectContext?.save()
            } catch {
                print(error)
            }
            
            mapView.addAnnotation(annotation)
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
        
        let coordinates = (mapView.selectedAnnotations[0] as! MKPointAnnotation).coordinate
        let latitude = coordinates.latitude as NSNumber
        let longitude = coordinates.longitude as NSNumber

        
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Pin", inManagedObjectContext: self.sharedContext)
        fetchRequest.entity = entityDescription
        
        let latPredicate = NSPredicate(format: "latitude == %@", latitude)
        let longPredicate = NSPredicate(format: "longitude == %@", longitude)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [latPredicate, longPredicate])
        
        fetchRequest.predicate = predicate
        var pinObject: AnyObject? = nil
        do {
            pinObject = try self.sharedContext.executeFetchRequest(fetchRequest)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        let pin = pinObject![0] as! Pin // here is the relevant pin
        
        
        
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Config.key)&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&format=json&nojsoncallback=1&per_page=20"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error == nil {
                var parsedResult: AnyObject? = nil
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                } catch {
                    print("fail whale")
                    return
                }
                
                var totalPhotos: Int?
                if let photos = parsedResult!["photos"] as? [String: AnyObject] {
                    if let photoGroup = photos["photo"] as? [[String: AnyObject]] {
                        totalPhotos = photoGroup.count
                        for photo in photoGroup {
                            let farmID = photo["farm"] as! Int
                            let serverID = photo["server"] as! String
                            let id = photo["id"] as! String
                            let secret = photo["secret"] as! String
                            
                            let url = NSURL(string: "https://farm\(farmID).staticflickr.com/\(serverID)/\(id)_\(secret).jpg")!
                            
                            let task = session.dataTaskWithURL(url) { data, response, error in
                                if error == nil {
                                    let image = UIImage(data: data!)!
                                    let photo = Photo(flickrPhoto: image, context: self.sharedContext)
                                    
                                    photo.pin = pin
                                    CoreDataStackManager.sharedInstance().saveContext()
//                                    pin.photos!.append(photo)
                                } else {
                                    print("shite")
                                    print(error!.localizedDescription)
                                    return
                                }
                            }
                            task.resume()
                        }
                    }
                }
                
                
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    PhotosCollectionViewController.pinTapped = pin
                    PhotosCollectionViewController.totalPhotos = totalPhotos
                    self.performSegueWithIdentifier("showPhotos", sender: self)
                }
                

            } else {
                print(error!.localizedDescription)
            }
        }
        task.resume()
        
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
    


}

