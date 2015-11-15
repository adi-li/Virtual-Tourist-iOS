//
//  BaseManagedObject.swift
//  Virtual Tourist
//
//  Created by Adi Li on 14/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import CoreData


class BaseManagedObject: NSManagedObject {
    
    // Entity name
    // should be overrided in subclass if not class name is not
    // the same as the entity name
    class var entityName: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    // Short-hand for create NSFetchRequest
    class func fetchRequest() -> NSFetchRequest {
        return NSFetchRequest(entityName: self.entityName)
    }
    
    // Short-hand for getting entityDescription in default NSManagedObjectContext
    class func entityDescription() -> NSEntityDescription {
        return self.entityDescriptionInManagedObjectContext(CoreDataStackManager.defaultManager.managedObjectContext)
    }
    
    // Short-hand for getting entityDescription in desired NSManagedObjectContext
    class func entityDescriptionInManagedObjectContext(context: NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entityForName(self.entityName, inManagedObjectContext: context)!
    }
    
    // Convenience init for create a new object in default NSManagedObjectContext
    convenience init() {
        let context = CoreDataStackManager.defaultManager.managedObjectContext
        self.init(insertIntoManagedObjectContext: context)
    }
    
    // Convenience init for create a new object in desired NSManagedObjectContext
    convenience init(insertIntoManagedObjectContext context: NSManagedObjectContext) {
        self.init(entity: self.dynamicType.entityDescriptionInManagedObjectContext(context),
            insertIntoManagedObjectContext: context)
    }
    
    // Short-hand for determine the object is saved or not
    var saved: Bool {
        return !objectID.temporaryID
    }
    
    // Short-hand for delete itself from context
    func delete() {
        managedObjectContext?.deleteObject(self)
    }
}