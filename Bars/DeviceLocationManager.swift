//
//  LocationManager.swift
//  Bars
//
//  Created by Mariano Latorre on 13/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import Foundation
import CoreLocation


protocol DeviceLocationDelegate: class {
    func locationFound()
}

protocol DeviceLocationSearchable {
    func setupManager(delegate: DeviceLocationDelegate)
    var latestLocation:CLLocation? {get}
}

/*
 DeviceLocationManager:
 - Keeps track of the latest user location "latestLocation"
 - Requests authorization to use device location
 */
class DeviceLocationManager : NSObject, DeviceLocationSearchable {
    
    private var locationManager = CLLocationManager()
    var latestLocation : CLLocation?
    weak var delegate : DeviceLocationDelegate!
    
    /* Setup the location manager and request authorization */
    func setupManager(delegate: DeviceLocationDelegate) {
        self.delegate = delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
}

extension DeviceLocationManager :CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        if(latestLocation == nil) {
            latestLocation = locations[locations.count - 1]
            manager.stopUpdatingLocation()
            delegate.locationFound()
        }
    }
}
