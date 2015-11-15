//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Adi Li on 14/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var imageURLString: String?
    @NSManaged var filePath: String?
    @NSManaged var pin: Pin?

}
