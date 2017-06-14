//
//  BarViewModel.swift
//  Bars
//
//  Created by Mariano Latorre on 13/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import Foundation
import MapKit

/*
 Actions available in the View
 */
protocol BarViewModelDelegate: class {
    func showBars()
    func showError(error: String)
}

/*
 Display Model for Bars, contains the only data needed by the View
 */
class BarDisplayModel {
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

class BarViewModel {
    
    fileprivate weak var delegate: BarViewModelDelegate?
    fileprivate let locationSearchService = LocationSearchService()
    static var dataSource : [BarDisplayModel]?
    
    fileprivate static var bars : [Place]? {
        willSet {
            guard let currentLocation = BarViewModel.currentLocation else {
                return
            }
            BarViewModel.dataSource = newValue?.map({
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
    fileprivate static var currentLocation : CLLocation?
    
    public init(withDelegate delegate: BarViewModelDelegate) {
        self.delegate = delegate
        
        if BarViewModel.currentLocation == nil {
            DeviceLocationManager.shared.setupManager(delegate: self)
        }else {
            retrieveBars()
        }
    }
    
    public func openGoogleMaps(item: Int) {
        let latitude =  BarViewModel.bars?[item].location.coordinate.latitude ?? 0
        let longitude =  BarViewModel.bars?[item].location.coordinate.longitude ?? 0
        
        let url = URL(string:"https://www.google.com/maps/@\(latitude),\(longitude),19z")!
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    public func retrieveBars(){
        
        guard BarViewModel.bars == nil else {
                self.delegate?.showBars()
                return
        }
        
        guard let currentLocation = BarViewModel.currentLocation else {
            delegate?.showError(error: "Error retrieving device location")
            return
        }
        
        let service = LocationSearchService()
        
        service.searchNearby(location: currentLocation, radius: 1000, type: .bar) {
            [weak self] (result) in
            
            guard let `self` = self else {
                return
            }
            
            DispatchQueue.main.async {
                switch(result) {
                case .error(let message):
                    self.delegate?.showError(error: message)
                case .success(let places):
                    BarViewModel.bars = places
                    self.delegate?.showBars()
                }
            }
        }
    }
}

extension BarViewModel : DeviceLocationSearchable {
    func locationFound() {
        BarViewModel.currentLocation = DeviceLocationManager.shared.latestLocation
        retrieveBars()
    }
}
