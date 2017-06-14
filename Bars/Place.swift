//
//  Bar.swift
//  Bars
//
//  Created by Mariano Latorre on 13/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import Foundation
import MapKit

/*
 Places Model Object
 */
class Place {

    var name: String
    var location: CLLocation
    
    init(name: String, location: CLLocation) {
        self.name = name
        self.location = location
    }
}
 
