//
//  ActionSheet.swift
//  ImageSearch
//
//  Created by Prabhdeep Singh on 26/11/20.
//  Copyright © 2020 Prabh. All rights reserved.
//

import Foundation
import UIKit

class ActionSheet {
    
    static func showImageOptions(for vc: ViewController,handler: (UIAlertController) -> Void) {
        
        let alert = UIAlertController(title: "Change View Style", message: "", preferredStyle: .actionSheet)
        
        let twoImages = UIAlertAction(title: "Two Images", style: .default, handler: { [weak vc] (action) in
            vc?.itemsPerRow = 2
        })
        
        let threeImages = UIAlertAction(title: "Three Images", style: .default, handler: { [weak vc] (action) in
            vc?.itemsPerRow = 3
        })
        
        let fourImages = UIAlertAction(title: "Four Images", style: .default, handler: { [weak vc] (action) in
            vc?.itemsPerRow = 4
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(twoImages)
        alert.addAction(threeImages)
        alert.addAction(fourImages)
        alert.addAction(cancelAction)
        //vc.present(alert, animated: true, completion: nil)
        handler(alert)
    }
    
}
