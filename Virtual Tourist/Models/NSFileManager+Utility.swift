//
//  NSFileManager+Utility.swift
//  Virtual Tourist
//
//  Created by Adi Li on 15/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation

extension NSFileManager {
    
    var applicationDocumentsDirectory: NSURL {
        let urls = self.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last!
    }
    
}