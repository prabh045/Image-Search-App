//
//  PhotoDetails.swift
//  ImageSearch
//
//  Created by Prabhdeep Singh on 27/11/20.
//  Copyright © 2020 Prabh. All rights reserved.
//

import Foundation
import UIKit

enum PhotoState {
    case new
    case downloaded
    case failed
}

class PhotoDetails {
    var flickrPhoto: Photo
    var imageUrl: URL?
    var state = Box(PhotoState.new)
    var image = UIImage(named: "Placeholder")
    
    init(flickrPhoto: Photo, imageUrl: URL?) {
        self.flickrPhoto = flickrPhoto
        self.imageUrl = imageUrl
    }
}
