//
//  Map.swift
//  Virtual Tourist
//
//  Created by Adi Li on 14/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Map: BaseManagedObject {
    
    // MARK: - Properties
    
    var center: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude!.doubleValue,
                longitude: longitude!.doubleValue)
        }
        
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    var span: MKCoordinateSpan {
        get {
            return MKCoordinateSpan(latitudeDelta: latitudeDelta!.doubleValue,
                longitudeDelta: longitudeDelta!.doubleValue)
        }
        
        set {
            latitudeDelta = newValue.latitudeDelta
            longitudeDelta = newValue.longitudeDelta
        }
    }
    
    var region: MKCoordinateRegion {
        get {
            return MKCoordinateRegion(center: center, span: span)
        }
        
        set {
            center = newValue.center
            span = newValue.span
        }
    }
    
}
