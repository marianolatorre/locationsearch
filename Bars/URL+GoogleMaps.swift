//
//  URL+GoogleMaps.swift
//  Bars
//
//  Created by Mobile Developer Lloyds Bank on 14/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import Foundation
import CoreLocation

/*
 URL extension to add new init method to open google maps universal link
 */
extension URL {
    init (location:CLLocation){
        
        let latitude =  location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        self = URL(string:"https://www.google.com/maps/@\(latitude),\(longitude),19z")!
    }
}
