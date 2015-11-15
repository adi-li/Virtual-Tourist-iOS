//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Adi Li on 14/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var currentMap: Map!
    var addingAnnotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCurrentMap()
        
        // Reset the map region if currentMap is saved before
        if currentMap.saved {
            mapView.setRegion(currentMap.region, animated: false)
        }
        
        // Add pins to mapView
        for pin in currentMap.pins as! Set<Pin> {
            addPin(pin)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
    }
    
    func loadCurrentMap() {
        // Try to get map object from context
        var results = [Map]()
        do {
            try results = CoreDataStackManager.defaultManager.managedObjectContext.executeFetchRequest(
                Map.fetchRequest()) as! [Map]
        } catch let error as NSError {
            print("executeFetchRequest error \(error),  \(error.userInfo)")
            abort()
        }
        
        // Create if not found
        if results.count == 0 {
            results = [Map()]
            CoreDataStackManager.defaultManager.saveContext()
        }
        
        currentMap = results.first!
    }
    
    // MARK: - Add pins
    
    func addPin(pin: Pin) {
        addPinWithCoordinate(pin.coordinate)
    }
    
    func addPinWithCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    
    // MARK: - MKMapViewDelegate
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        // Set region if currentMap if it is not saved
        if !currentMap.saved {
            currentMap.region = mapView.region
            // Save the context to make currentMap is saved
            CoreDataStackManager.defaultManager.saveContext()
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Set region whenever the mapView region changed
        currentMap.region = mapView.region
        CoreDataStackManager.defaultManager.saveContext()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
        pinView.animatesDrop = true
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let coordinate = view.annotation!.coordinate
        let request = Pin.fetchRequest()
        let results: [Pin]
        request.predicate = NSPredicate(format: "latitude = %lf AND longitude = %lf",
            coordinate.latitude, coordinate.longitude)
        do {
            try results = CoreDataStackManager.defaultManager.managedObjectContext.executeFetchRequest(request) as! [Pin]
        } catch let error as NSError {
            print("Cannot find pin \(error), \(error.userInfo)")
            return
        }
        let pin = results.first!
        performSegueWithIdentifier("MapToAlbumSegue", sender: pin)
    }
    
    
    // MARK: - User actions
    
    @IBAction func addPinWithLongPress(sender: UILongPressGestureRecognizer) {
        let point = sender.locationInView(mapView)
        let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        switch sender.state {
            
        case .Began:
            // Drop pin while long press began
            addingAnnotation = MKPointAnnotation()
            addingAnnotation!.coordinate = coordinate
            mapView.addAnnotation(addingAnnotation!)
            
        case .Changed:
            // Drag pin if user is dragging
            addingAnnotation!.coordinate = coordinate
            
        case .Ended:
            // Create pin when long press ended
            let pin = Pin()
            pin.coordinate = coordinate
            pin.map = currentMap
            CoreDataStackManager.defaultManager.saveContext()
            
            // pre-fetch flickr photos
            pin.fetchFlickrPhotos(false, completion: { (photos, error) -> Void in
                guard error == nil else {
                    return
                }
                CoreDataStackManager.defaultManager.saveContext()
            })
            addingAnnotation = nil
            
        case .Failed:
            // Fallthrough for removing addingAnnotation
            fallthrough
        case .Cancelled:
            if addingAnnotation != nil {
                mapView.removeAnnotation(addingAnnotation!)
            }
            fallthrough
        default:
            addingAnnotation = nil
            break
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MapToAlbumSegue" {
            guard let pin = sender as? Pin else {
                return
            }
            
            let vc = segue.destinationViewController as! PhotoAlbumViewController
            vc.pin = pin
        }
    }

}
