//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Adi Li on 14/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photo: BaseManagedObject {
    
    // MARK: - Properties
    
    var imageURL: NSURL {
        return NSURL(string: self.imageURLString!)!
    }
    
    var filename: String {
        return self.imageURL.lastPathComponent!
    }
    
    var fileURL: NSURL {
        let directory = NSFileManager.defaultManager().applicationDocumentsDirectory
        return directory.URLByAppendingPathComponent(filename)
    }
    
    var image: UIImage? {
        guard let data = NSData(contentsOfURL: fileURL) else {
            return nil
        }
        
        return UIImage(data: data)
    }
    
    var isDownloaded: Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!)
    }
    
    // MARK: - Download image
    
    func downloadImage(completion: ((NSError?) -> Void)?) {
        ImageDownloader.downloader.downloadImageWithURL(imageURL, toFileURL: fileURL) { (error) -> Void in
            guard error == nil else {
                completion?(error)
                return
            }
            
            // Save the fileURL.path if successfully downloaded
            self.filePath = self.fileURL.path
            
            completion?(nil)
        }
    }
    
    // Get image if it is downloaded, otherwise download it and return
    func imageWithCompletion(completion: ((UIImage?, NSError?) -> Void)?) {
        if let img = image {
            completion?(img, nil)
            return
        }
        
        downloadImage { (error) -> Void in
            guard error == nil else {
                completion?(nil, error)
                return
            }
            
            completion?(self.image, nil)
        }
    }
    
    // MARK: - Deletion
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        
        guard isDownloaded else {
            return
        }
        
        // Delete the underlying file also
        do {
            try NSFileManager.defaultManager().removeItemAtURL(fileURL)
        } catch let error as NSError {
            print("Delete file error \(error), \(error.userInfo)")
        }
    }
}
