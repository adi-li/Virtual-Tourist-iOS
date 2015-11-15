//
//  FlickrAPIClient.swift
//  Virtual Tourist
//
//  Created by Adi Li on 15/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import MapKit

class FlickrAPIClient: APIClient {
    
    static let client = FlickrAPIClient()
    
    override class var BaseURL: NSURL { return NSURL(string: "https://api.flickr.com/services/rest/")! }
    
    
    func searchPhotosWithLocation(location: CLLocationCoordinate2D, completion: CompletionHandler?) {
        let parameters = [
            "method": "flickr.photos.search",
            "api_key": self.dynamicType.key,
            "format": "json",
            "nojsoncallback": "1",
            "lat": "\(location.latitude)",
            "lon": "\(location.longitude)",
            "extras": "url_s"
        ]
        taskForGET("", parameters: parameters, completion: completion)
    }
}
