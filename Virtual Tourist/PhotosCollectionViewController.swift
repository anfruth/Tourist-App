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
        navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionOfPhotos.reloadData()
    }
    
//    @IBAction func getNewImages(sender: UIBarButtonItem) {
//        let fetchRequest = NSFetchRequest()
//        let entityDescription = NSEntityDescription.entityForName("Photo", inManagedObjectContext: sharedContext)
//        fetchRequest.entity = entityDescription
//        
//        let predicate = NSPredicate(format: "photos.pin == %@", PhotosCollectionViewController.pinTapped!)
//        fetchRequest.predicate = predicate
//        
//        var photoObject: AnyObject? = nil
//        do {
//            photoObject = try sharedContext.executeFetchRequest(fetchRequest)
//        } catch {
//            let fetchError = error as NSError
//            print(fetchError)
//        }
//        
////        return pinObject![0] as! Pin // here is the relevant pin
//
//        
//        collectionOfPhotos.reloadData()
//    }
    
    lazy var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", PhotosCollectionViewController.pinTapped!)
        
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
    
    // NSFetchedResultsControllerDelegate
    
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
                // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
                // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
                // the index path that we want in this case
                insertedIndexPaths.append(newIndexPath!)
                break
            case .Delete:
                print("Delete an item")
                // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
                // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
                // value that we want in this case.
                deletedIndexPaths.append(indexPath!)
                break
            case .Update:
                print("Update an item.")
                // We don't expect Color instances to change after they are created. But Core Data would
                // notify us of changes if any occured. This can be useful if you want to respond to changes
                // that come about after data is downloaded. For example, when an images is downloaded from
                // Flickr in the Virtual Tourist app
                updatedIndexPaths.append(indexPath!)
                break
            case .Move:
                print("Move an item. We don't expect to see this in this app.")
                break
            }

    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
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
