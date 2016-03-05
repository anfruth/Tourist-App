//
//  ApiClient.swift
//  Virtual Tourist
//
//  Created by Andrew Fruth on 2/24/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

struct ApiClient {
    
    static func retrievePhotos(coordinates: CLLocationCoordinate2D, pin: Pin, context: NSManagedObjectContext) {
        
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Config.key)&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&format=json&nojsoncallback=1&per_page=500"
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error == nil {
                var parsedResult: AnyObject? = nil
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                } catch {
                    print("Failed Parsing JSON")
                    return // could cause problems
                }
                
                downloadAllImages(parsedResult, pin: pin, session: session, context: context)
                
            } else {
                print(error!.localizedDescription)
            }
        }
        task.resume()
    }
    
    private static func downloadAllImages(parsedResult: AnyObject?, pin: Pin, session: NSURLSession, context: NSManagedObjectContext) {
        if let photos = parsedResult!["photos"] as? [String: AnyObject] {
            if var photoGroup = photos["photo"] as? [[String: AnyObject]] {
                
                let numberOfPhotosToIterate: Int = {
                    if photoGroup.count < 20 {
                        return photoGroup.count
                    } else {
                        return 20
                    }
                }()
                
                
                for (var i = 0; i < numberOfPhotosToIterate; ++i) {
                    
                    let randomIndex = Int(arc4random_uniform(UInt32(photoGroup.count)))
                    let photo = photoGroup[randomIndex]
                    photoGroup.removeAtIndex(randomIndex)
                    
                    ApiClient.getEndpointForImage(photo, pin: pin, session: session, context: context, handler: {endpoint, photo in
                        ApiClient.downloadImage(endpoint, session: session, photo: photo)
                    })
                    
                }
            }
        }
    }
    
    private static func getEndpointForImage(photo: [String: AnyObject], pin: Pin, session: NSURLSession, context: NSManagedObjectContext, handler: (endpoint: NSURL, photo: Photo) -> ()) -> () {
        
        let farmID = photo["farm"] as! Int
        let serverID = photo["server"] as! String
        let id = photo["id"] as! String
        let secret = photo["secret"] as! String
        
        
        dispatch_async(dispatch_get_main_queue(), {
            let photo = Photo(flickrPhoto: nil, context: context)
            photo.pin = pin
            CoreDataStackManager.sharedInstance().saveContext()
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                let endpoint = NSURL(string: "https://farm\(farmID).staticflickr.com/\(serverID)/\(id)_\(secret).jpg")!
                handler(endpoint: endpoint, photo: photo)
            })
        })
        
    }
    
    private static func downloadImage(url: NSURL, session: NSURLSession, photo: Photo) {
        
        let task = session.dataTaskWithURL(url) { data, response, error in
            
            if error == nil {
                let image = UIImage(data: data!)!
                dispatch_async(dispatch_get_main_queue(), {
                    photo.addImage(image)
                    CoreDataStackManager.sharedInstance().saveContext()
                })
            } else {
                print("shite")
                print(error!.localizedDescription)
                return
            }
        }
        task.resume()
    }
    
    
}