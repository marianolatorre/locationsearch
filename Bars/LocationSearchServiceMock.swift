//
//  LocationSearchServiceMock.swift
//  Bars
//
//  Created by Mobile Developer Lloyds Bank on 14/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import Foundation
import CoreLocation


class LocationSearchServiceMock :LocationSearchable {
    
    func searchNearby(location: CLLocation, radius: Int, type: LocationType, callback: @escaping (Result<[Place]>) -> Void) {
        
        if let file = Bundle.main.url(forResource: "locationSearchResponse", withExtension: "json") {
            let data = try! Data(contentsOf: file)
            
            let locationResponseParser = LocationResponseParser()
            
            locationResponseParser.parseLocationSeachResponse(responseData:data){
                result in
                switch(result) {
                case .error(let message):
                    callback(.error(message:message))
                case .success(let places):
                    callback(.success(response:places))
                }
                
            }
        }
    }
}
