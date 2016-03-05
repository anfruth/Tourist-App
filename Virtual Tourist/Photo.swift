//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Andrew Fruth on 2/15/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class Photo : NSManagedObject {
    
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin
    @NSManaged var id: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(flickrPhoto: UIImage?, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = NSUUID().UUIDString
        
        if flickrPhoto != nil {
            imagePath = Caches.imageCache.pathForIdentifier(id + ".jpg")
        }
        
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    func addImage(flickrPhoto: UIImage) {
        imagePath = Caches.imageCache.pathForIdentifier(id)
        Caches.imageCache.storeImage(flickrPhoto, withIdentifier: id + ".jpg")
    }
    
    func retrieveImage() -> UIImage? {
        if imagePath != nil {
           return Caches.imageCache.imageWithIdentifier(id + ".jpg")
        }
        return nil
    }
    
    
}
