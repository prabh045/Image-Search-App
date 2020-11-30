//
//  FlickrAPI.swift
//  ImageSearch
//
//  Created by Prabhdeep Singh on 26/11/20.
//  Copyright © 2020 Prabh. All rights reserved.
//

import Foundation

class FlickrAPI {
    
   // private let API_KEY = "ec0b5a7c0f204a088f6df9122c4ea3b9"
    private var API_KEY : String {
      get {
        guard let filePath = Bundle.main.path(forResource: "Flickr-Info", ofType: "plist") else {
          fatalError("Couldn't find file 'Flickr-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key API_KEY")
        }
        return value
      }
    }
    static let shared = FlickrAPI()
    
    private init() {
    }
    
    func fetchData(for text: String,atPage page: Int, completion: @escaping(FlickrPhoto?,Error?) -> Void) {
        
        let urlString = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&text=\(text)&per_page=10&page=\(page)&format=json&nojsoncallback=1"
        
        guard let url = URL(string: urlString) else {
            completion(nil,nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, respone, error) in
            
            if let error = error {
                print("Error in fetching data \(error.localizedDescription)")
                completion(nil,error)
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            
            guard let response = respone as? HTTPURLResponse else {
                print("Inavlid response")
                return
            }
            guard response.statusCode == 200 else {
                print("Wrong status code \(response.statusCode)")
                return
            }
            
            do {
                let photo = try JSONDecoder().decode(FlickrPhoto.self, from: data)
                completion(photo,nil)
            } catch let error{
                completion(nil,error)
            }

        }.resume()
    }
    
    
}

