//
//  PhotoAlbumViewCell.swift
//  Virtual Tourist
//
//  Created by Adi Li on 15/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

class PhotoAlbumViewCell: UICollectionViewCell {
    
    static let Identifier = "PhotoAlbumViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var photo: Photo? {
        didSet {
            didSetPhoto(photo)
        }
    }
    
    func didSetPhoto(photo: Photo?) {
        imageView.image = nil
        
        guard photo != nil else {
            return
        }
        
        loadingIndicator.startAnimating()
        
        photo!.imageWithCompletion { (image, error) -> Void in
            self.loadingIndicator.stopAnimating()
            
            guard error == nil else {
                return
            }
            
            guard photo == self.photo else {
                return
            }
            
            self.imageView.image = image!
        }
    }
}
