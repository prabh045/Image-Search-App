//
//  ImageViewController.swift
//  ImageSearch
//
//  Created by Prabhdeep Singh on 30/11/20.
//  Copyright © 2020 Prabh. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var photoDetails: PhotoDetails!
    var pendingOperations = PendingImageOperations()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = photoDetails.image
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(imageView)
        setupConstraints()
        downloadImageFor(photoDetails: photoDetails)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
    }
    
    func downloadImageFor(photoDetails: PhotoDetails) {
        photoDetails.imageUrl = photoDetails.flickrPhoto.getImageURL("z")
        let imageDownloader = ImageDownloader(photoDetails: photoDetails)
        imageDownloader.completionBlock = { [weak self] in
            if imageDownloader.isCancelled {
              return
            }
            DispatchQueue.main.async {
                self?.imageView.image = photoDetails.image
            }
            print("Image operation completed")
        }
        pendingOperations.downloadsQueue.addOperation(imageDownloader)
        
    }
    
    deinit {
        pendingOperations.downloadsQueue.cancelAllOperations()
    }
    
}
