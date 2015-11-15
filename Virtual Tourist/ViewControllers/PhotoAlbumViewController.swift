//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Adi Li on 14/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var isLoading = false {
        didSet {
            collectionView.hidden = isLoading
            noImagesLabel.hidden = isLoading
            newCollectionButton.enabled = !isLoading
            if isLoading {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        }
    }
    
    var pin: Pin!
    lazy var fetchResultsController: NSFetchedResultsController = {
        let request = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "pin = %@", self.pin)
        request.sortDescriptors = [NSSortDescriptor(key: "imageURLString", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: request,
            managedObjectContext: CoreDataStackManager.defaultManager.managedObjectContext,
            sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set region for map
        let region = MKCoordinateRegion(center: pin.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        mapView.setRegion(region, animated: false)
        
        // Add pin for map
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        mapView.addAnnotation(annotation)
        
        // Perform fetch photos
        pin.fetchFlickrPhotos(false) { (photos, error) -> Void in
            guard error == nil else {
                return
            }
            
            do {
                try self.fetchResultsController.performFetch()
            } catch let error as NSError {
                print("Cannot find photos \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Collection view data source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = fetchResultsController.fetchedObjects?.count ?? 0
        
        let noPhotos = count == 0
        
        collectionView.hidden = noPhotos || isLoading
        noImagesLabel.hidden = !noPhotos || isLoading
        
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoAlbumViewCell.Identifier, forIndexPath: indexPath) as! PhotoAlbumViewCell
        cell.photo = fetchResultsController.objectAtIndexPath(indexPath) as? Photo
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = fetchResultsController.objectAtIndexPath(indexPath) as! Photo
        photo.delete()
        CoreDataStackManager.defaultManager.saveContext()
    }
    
    // MARK: - User actions
    
    @IBAction func fetchNewCollection(sender: UIButton) {
        isLoading = true
        
        let photos = pin.photos as! Set<Photo>
        for photo in photos {
            photo.delete()
        }
        
        CoreDataStackManager.defaultManager.saveContext()
        
        pin.fetchFlickrPhotos(true) { (photos, error) -> Void in
            self.isLoading = false
            
            guard error == nil else {
                return
            }
            
            CoreDataStackManager.defaultManager.saveContext()
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.reloadData()
    }
}
