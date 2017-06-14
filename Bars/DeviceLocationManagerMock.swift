//
//  DeviceLocationManagerMock.swift
//  Bars
//
//  Created by Mariano Latorre on 14/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import Foundation
import CoreLocation

class DeviceLocationManagerMock : DeviceLocationSearchable {

    weak var delegate : DeviceLocationDelegate!
    var latestLocation:CLLocation?
    
    func setupManager(delegate: DeviceLocationDelegate) {
        self.delegate = delegate
        delegate.locationFound()
    }
}
