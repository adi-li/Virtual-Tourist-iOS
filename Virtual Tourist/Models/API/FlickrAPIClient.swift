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
    
    
    func searchPhotosWithLocation(location: CLLocationCoordinate2D, page: Int, completion: CompletionHandler?) {
        let parameters: [String : AnyObject] = [
            ParameterKey.Method: MethodOption.PhotoSearch.rawValue,
            ParameterKey.Format: FormatOption.JSON.rawValue,
            ParameterKey.NoJSONCallback: NoJSONCallbackOption.Yes.rawValue,
            ParameterKey.APIKey: self.dynamicType.key,
            ParameterKey.Latitude: location.latitude,
            ParameterKey.Longitude: location.longitude,
            ParameterKey.Page: page,
            ParameterKey.PerPage: 20 + Int(arc4random_uniform(11)),
            ParameterKey.Extras: ExtrasOption.SmallImageURL,
        ]
        taskForGET("", parameters: parameters, completion: completion)
    }
}
