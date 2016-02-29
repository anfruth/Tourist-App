//
//  PhotosCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Andrew Fruth on 2/14/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotosCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionOfPhotos: UICollectionView!

    let cellReuseIdentifier = "photoCollectionViewCell"
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    static var pinTapped: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.hidden = false
        navigationController?.toolbar.hidden = false
    }
    
    @IBAction func getNewImages(sender: UIBarButtonItem) {
        
        let photoObject = CoreDataLookup.retrievePinPhotos(sharedContext)
        let photos = photoObject as! [Photo]
        
        for photo in photos {
           sharedContext.deleteObject(photo)
        }
        
        let latitude = PhotosCollectionViewController.pinTapped!.latitude as Double
        let longitude = PhotosCollectionViewController.pinTapped!.longitude as Double
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        ApiClient.retrievePhotos(coordinates, pin: PhotosCollectionViewController.pinTapped!, context: sharedContext)
    }
    
    lazy var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", PhotosCollectionViewController.pinTapped!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
        
    }()
    
    // Collection

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        print("number Of Cells: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! PhotosCollectionViewCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        cell.photo?.image = photo.retrieveImage()
        if cell.photo?.image == nil {
           cell.placeholderText.hidden = false
        } else {
            cell.placeholderText.hidden = true
        }
        cell.placeholderText.text = "LOADING"
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        let fetchRequest = CoreDataLookup.setupFetchRequest("Photo", context: sharedContext)
        
        let predicate = NSPredicate(format: "id == %@", photo.id)
        fetchRequest.predicate = predicate
    
        let photoObject = CoreDataLookup.executeFetchRequest(sharedContext, fetchRequest: fetchRequest)
        let coreDataPhoto = photoObject as! [Photo]

        sharedContext.deleteObject(coreDataPhoto[0])
        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    // NSFetchedResultsControllerDelegate - from color App
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
            switch type{
                
            case .Insert:
                print("Insert an item")
                insertedIndexPaths.append(newIndexPath!)
                break
            case .Delete:
                print("Delete an item")
                deletedIndexPaths.append(indexPath!)
                break
            case .Update:
                print("Update an item.")
                updatedIndexPaths.append(indexPath!)
                break
            case .Move:
                break
            }

    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        print("in controllerDidChangeContent. changes.count: \(updatedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionOfPhotos.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionOfPhotos.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionOfPhotos.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionOfPhotos.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
}
