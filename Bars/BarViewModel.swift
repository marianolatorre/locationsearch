//
//  BarViewModel.swift
//  Bars
//
//  Created by Mariano Latorre on 14/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import Foundation
import MapKit

/*
 Actions available in the View
 */
protocol BarViewModelDelegate: class {
    func showBars()
    func showError(message: String)
}

/*
 Display Model for Bars, contains the only data needed by the View
 */
struct BarDisplayModel {
    let name: String
    let distance: Double
    let location: CLLocation
    let annotation: MKPointAnnotation    
    
    init(name: String, distance: Double, location: CLLocation, annotation:MKPointAnnotation) {
        self.name = name
        self.distance = distance
        self.location = location
        self.annotation = annotation
    }
}

/*
 Bar View Model
 */
class BarViewModel {
    
    // dataSource can be consumed by the views
    public var dataSource : [BarDisplayModel]?
    
    // delegate actions that the view can perform
    fileprivate weak var delegate: BarViewModelDelegate?
    
    // protocol injectable properties to facilitate testing
    let locationSearchService : LocationSearchable!
    let locationManager : DeviceLocationSearchable!
    
    fileprivate var currentLocation : CLLocation?
    
    fileprivate var bars : [Place]? {
        willSet {
            guard let currentLocation = currentLocation else {
                return
            }
            dataSource = newValue?.map({
                let distanceMeters = $0.location.distance(from:currentLocation)
                let distanceKm =  Double(round(10*(distanceMeters/1000))/10)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = $0.location.coordinate
                annotation.title = $0.name
                annotation.subtitle = "\(distanceKm) Km"

                return BarDisplayModel(name:$0.name, distance: distanceKm, location: $0.location, annotation: annotation)
            })
        }
    }
    
    /*
     Initializers
     */
    convenience public init(withDelegate delegate: BarViewModelDelegate) {
        self.init(withDelegate: delegate, locationManager: nil, locationSearchService: nil)
    }
    
    public init(withDelegate delegate: BarViewModelDelegate,
                locationManager:DeviceLocationSearchable?,
                locationSearchService: LocationSearchable? ){

        self.delegate = delegate
        self.locationManager = locationManager ?? DeviceLocationManager()
        self.locationSearchService = locationSearchService ?? LocationSearchService(withParser:LocationResponseParser())
        self.locationManager.setupManager(delegate: self)
    }
    
    public func openGoogleMaps(item: Int) {
        guard let location = bars?[item].location else {
            return
        }
        
        let url = URL(location:location)
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    public func retrieveBars(){
        
        guard let currentLocation = currentLocation else {
            delegate?.showError(message: "Error retrieving device location")
            return
        }
        
        self.locationSearchService.searchNearby(location: currentLocation, radius: 1000, type: .bar) {
            [weak self] (result) in
            
            guard let `self` = self else {
                return
            }
            
            DispatchQueue.main.async {
                switch(result) {
                case .error(let message):
                    self.delegate?.showError(message: message)
                case .success(let places):
                    self.bars = places
                    self.delegate?.showBars()
                }
            }
        }
    }
}

extension BarViewModel : DeviceLocationDelegate {
    func locationFound() {
        currentLocation = locationManager.latestLocation
        retrieveBars()
    }
}
