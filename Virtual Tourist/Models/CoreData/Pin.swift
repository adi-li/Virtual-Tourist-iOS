//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Adi Li on 14/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: BaseManagedObject {
    
    // MARK: - Properties
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude!.doubleValue,
                longitude: longitude!.doubleValue)
        }
        
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    var name: String {
        return "\(latitude!)-\(longitude!)".stringByReplacingOccurrencesOfString(".", withString: "_")
    }
    
    // MARK: - Fetching photos
    
    func fetchFlickrPhotos(force: Bool, completion: (([Photo]?, NSError?) -> Void)?) {
        if lastFetchedPage!.integerValue > 0 && force == false {
            // Return immediately if fetching is done
            // and not force re-fetch
            completion?(Array(photos as! Set), nil)
            return
        }
        
        var page: Int
        repeat {
            page = 1 + Int(arc4random_uniform(10))
        } while (lastFetchedPage!.integerValue == page)
        
        lastFetchedPage = page
        
        FlickrAPIClient.client.searchPhotosWithLocation(self.coordinate, page: lastFetchedPage!.integerValue) { (data, error) -> Void in
            
            // Ensure no error
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.lastFetchedPage = 0
                    completion?(nil, error)
                }
                return
            }
            
            // Ensure data is dictionary
            guard let dict = data as? [String: AnyObject] else {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    let parsingError = NSError(domain: "VirtualTouristErrorDomain", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Cannot parse data"
                    ])
                    self.lastFetchedPage = 0
                    completion?(nil, parsingError)
                }
                return
            }
            
            // Ensure data[photos][photo] exists
            guard let photosData = dict["photos"]?["photo"] as? [[String: AnyObject]] else {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    let parsingError = NSError(domain: "VirtualTouristErrorDomain", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Cannot parse data[photos][photo]"
                    ])
                    self.lastFetchedPage = 0
                    completion?(nil, parsingError)
                }
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                // Create photos and return
                
                var photos = [Photo]()
                
                for photoData in photosData {
                    if let imageURLString = photoData["url_s"] as? String {
                        let photo = Photo()
                        photo.imageURLString = imageURLString
                        photo.pin = self
                        photos.append(photo)
                    }
                }
                
                completion?(photos, nil)
            }
        }
    }

}
