//
//  AppDelegate.swift
//  Bars
//
//  Created by Mariano Latorre on 13/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Request for access to device location when app is in use
        // this will prompt the user for permission
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        
        return true
    }

}

