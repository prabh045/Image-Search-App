//
//  FlickrPhoto.swift
//  ImageSearch
//
//  Created by Prabhdeep Singh on 26/11/20.
//  Copyright © 2020 Prabh. All rights reserved.
//

import Foundation

struct FlickrPhoto: Decodable {
    var photos: Photos
    var stat: String
}

struct Photos: Decodable {
    var page: Int
    var pages: Int
    var perpage: Int
    var photo: [Photo]
}

struct Photo: Decodable {
    var id: String
    var farm: Int
    var server: String
    var secret: String
    
    func getImageURL(_ size: String = "m") -> URL? {
      if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg") {
        return url
      }
      return nil
    }
}



