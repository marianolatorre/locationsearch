//
//  SecondViewController.swift
//  Bars
//
//  Created by Mariano Latorre on 13/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: BaseViewController {

    var barViewModel : BarViewModel!
    var locationUpdated = false
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barViewModel = BarViewModel(withDelegate:self)
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
}

extension MapViewController : BarViewModelDelegate {
    func showBars(){
        let annotations = BarViewModel.dataSource?.map({$0.annotation})
        
        if let annotations = annotations {
            mapView.addAnnotations(annotations)
        }
    }
    func showError(error: String){
        present(errorMessage:error)
    }
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        guard locationUpdated == false else {
            return
        }
        
        locationUpdated = true
        
        let region = MKCoordinateRegionMakeWithDistance(
            userLocation.location!.coordinate, 2000, 2000)
        
        mapView.setRegion(region, animated: true)
    }
}
