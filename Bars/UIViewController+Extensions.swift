//
//  UIViewController+Extensions.swift
//  Bars
//
//  Created by Mobile Developer Lloyds Bank on 14/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func present(errorMessage: String){
        
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { action in
            
        })
        self.present(alertController, animated: true, completion:nil)
    }
}