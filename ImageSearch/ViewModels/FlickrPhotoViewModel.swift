//
//  FlickrPhotoViewModel.swift
//  ImageSearch
//
//  Created by Prabhdeep Singh on 27/11/20.
//  Copyright © 2020 Prabh. All rights reserved.
//

import Foundation
import UIKit.UIImage

class FlickrPhotoViewModel {
    
    //MARK: Properties
    private var flickrPhotos: [FlickrPhoto] = []
    private var pendingOperations = PendingImageOperations()
    
    var photoDetails = Box([PhotoDetails]())
    var photosCount = Box(0)
    
    var isInitialDataLoaded: Bool = false
    var currentPage = 1
    var imageUrlArray: [URL?] = []
    var searchText = "dogs"
    
    //MARK: Methods
    func search(text: String = "dogs") {
        
        if searchText != text {
            searchText = text
            resetData()
        }
        
        FlickrAPI.shared.fetchData(for: searchText, atPage: currentPage) { (flickrphoto, error) in
            if let error = error, flickrphoto == nil {
                print("Error fetching data \(error.localizedDescription)")
                return
            }
            self.flickrPhotos.append(flickrphoto!)
            
            self.photoDetails.value = self.photoDetails.value + flickrphoto!.photos.photo.map { (photo) in
                let photoDetails = PhotoDetails(flickrPhoto: photo, imageUrl: photo.getImageURL())
                return photoDetails
            }
            
            self.isInitialDataLoaded = true
            self.currentPage += 1
            self.photosCount.value = self.photosCount.value + flickrphoto!.photos.perpage
            print("Photo data is \(self.photoDetails.value)")
        }
    }
    
    private func resetData() {
        flickrPhotos.removeAll()
        photoDetails.value.removeAll()
        isInitialDataLoaded = false
        currentPage = 1
        imageUrlArray.removeAll()
        photosCount.value = 0
        pendingOperations.downloadsQueue.cancelAllOperations()
        pendingOperations.downloadsInProgress.removeAll()
    }
    
    //MARK: Operation Methods
    func downloadImageFor(photoDetails: PhotoDetails,indexPath: IndexPath) {
       
        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        let imageDownloader = ImageDownloader(photoDetails: photoDetails)
        
        imageDownloader.completionBlock = {
            if imageDownloader.isCancelled {
              return
            }
            print("Image operation completed")
        }
        
        pendingOperations.downloadsInProgress[indexPath] = imageDownloader
        pendingOperations.downloadsQueue.addOperation(imageDownloader)
    }
        
    func decreasePriorityForOperation(at indexPath: IndexPath) {
        guard let operation = pendingOperations.downloadsInProgress[indexPath] else {
            print("Operation is not present")
            return
        }
        if operation.isExecuting {
            print("Priority set to low")
            operation.queuePriority = .low
        }
    }
    
    func increasePriorityForOperation(at indexPath: IndexPath) {
        guard let operation = pendingOperations.downloadsInProgress[indexPath] else {
            print("Operation is not present")
            return
        }
        if operation.isExecuting {
            print("Priority set to normal")
            operation.queuePriority = .normal
        }
    }

    
}
