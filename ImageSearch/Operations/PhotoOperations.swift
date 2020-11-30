//
//  PhotoOperations.swift
//  ImageSearch
//
//  Created by Prabhdeep Singh on 27/11/20.
//  Copyright © 2020 Prabh. All rights reserved.
//

import Foundation
import UIKit

class PendingImageOperations {
    lazy var downloadsInProgress: [IndexPath:Operation] = [:]
    lazy var downloadsQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Image Download queue"
        return queue
    }()
}

class ImageDownloader: Operation{
    
    let photoDetails: PhotoDetails
    
    init(photoDetails: PhotoDetails) {
        self.photoDetails = photoDetails
    }
    
    override func main() {
        
        if isCancelled {
            print("Image opeartion cancelled")
            return
        }
        
        guard let imageUrl = self.photoDetails.imageUrl else {
            photoDetails.state.value = .failed
            photoDetails.image = UIImage(named: "Placeholder")
            print("Image opeartion failed")
            return
        }
        
        guard let imageData = try? Data(contentsOf: imageUrl) else {
            return
        }
        
        if isCancelled {
            print("Image opeartion cancelled")
            return
        }
        
        if imageData.isEmpty == false {
            photoDetails.image = UIImage(data:imageData)
            photoDetails.state.value = .downloaded
        } else {
            photoDetails.state.value = .failed
            photoDetails.image = UIImage(named: "Placeholder")
        }
        print("Image set successfully")
    }
    
}
