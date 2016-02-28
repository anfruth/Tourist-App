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
    
    @NSManaged var image: NSData?
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
            image = UIImageJPEGRepresentation(flickrPhoto!, 1)!
        }
        
    }
    
    func addImage(flickrPhoto: UIImage) {
        image = UIImageJPEGRepresentation(flickrPhoto, 1)!
    }
    
    func retrieveImage() -> UIImage? {
        if image != nil {
            return UIImage(data: image!)!
        }
        return nil
    }
    
    
}
