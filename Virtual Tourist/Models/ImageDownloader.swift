//
//  ImageDownloader.swift
//  Virtual Tourist
//
//  Created by Adi Li on 15/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader {
    
    typealias CompletionHandler = (NSError?) -> Void
    
    static let downloader = ImageDownloader()
    
    var session = NSURLSession.sharedSession()
    var downloadingTasks = [NSURL: [CompletionHandler?]]()
    // For atomic downloading tasks change
    let semaphore = dispatch_semaphore_create(1)
    
    func downloadImageWithURLString(URLString: String, toFileURL path: NSURL, completion: CompletionHandler?) {
        guard let URL = NSURL(string: URLString) else {
            return
        }
        downloadImageWithURL(URL, toFileURL: path, completion: completion)
    }
    
    func downloadImageWithURL(URL: NSURL, toFileURL path: NSURL, completion: CompletionHandler?) {
        downloadImageWithRequest(NSURLRequest(URL: URL), toFileURL: path, completion: completion)
    }
    
    func downloadImageWithRequest(request: NSURLRequest, toFileURL path: NSURL, completion: CompletionHandler?) {
        
        // Make this function atomic
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        defer {
            dispatch_semaphore_signal(semaphore)
        }
        
        // If key path exist, means downloading, return immedaiately
        guard downloadingTasks[path] == nil else {
            downloadingTasks[path]!.append(completion)
            return
        }
        
        // Append new completion
        downloadingTasks[path] = []
        downloadingTasks[path]!.append(completion)
        
        let task = session.downloadTaskWithRequest(request) { (URL, response, error) -> Void in
            
            // Remove task when it is done
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
            let completions = self.downloadingTasks[path]!
            self.downloadingTasks.removeValueForKey(path)
            dispatch_semaphore_signal(self.semaphore)
            
            // Error handling
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion?(error)
                })
                return
            }
            
            // Ensure URL is not nil
            guard URL != nil else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let error = NSError(domain: "VirtualTouristErrorDomain", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "Cannot find downloaded file"
                    ])
                    completion?(error)
                })
                return
            }
            
            // Copy file
            do {
                try NSFileManager.defaultManager().copyItemAtURL(URL!, toURL: path)
            } catch let error as NSError {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion?(error)
                })
                return
            }
            
            // Run all completions queue
            for completion in completions {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion?(nil)
                })
            }
        }
        
        // Start task
        task.resume()
    }
}