//
//  BarService.swift
//  Bars
//
//  Created by Mariano Latorre on 14/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

/*
 Supported place types
 */
enum LocationType: String {
    case bar = "bar"
    case restaurant = "restaurant"
}

/*
 Possible service errors
 TODO: this should by subclass of NSError instead and contain Domain
 TODO: Support for localisation
 */
enum LocationServiceError: String {
    case parsing = "Error while parsing json data"
    case jsonSerialization = "Error while using JSON serialization"
    case noData = "We did not receive data"
    case urlSetup = "Failed to create URL object"
    case internetNotAvailable = "Internet is not available, check your connection"
}

enum Result<T> {
    case success(response: T)
    case error(message: String)
}

protocol LocationSearchable {
    func searchNearby(location: CLLocation, radius: Int, type: LocationType, callback: @escaping (Result<[Place]>) -> Void)
}

protocol LocationResponseParsable {
    func parseLocationSeachResponse(responseData: Data, callback: @escaping (Result<[Place]>) -> Void)
}

class LocationSearchService : LocationSearchable, InternetReachable {
    
    private var locationResponseParser : LocationResponseParsable!
    var session = URLSession(configuration: URLSessionConfiguration.default)
    
    /*
     Request constants
     */
    private struct Constants {
        static let placesURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        static let placesKey = "AIzaSyBzyt8Zmv0iErg51va2F7NNBz76-4EABQw"
    }
    
    /*
     Request params we need to set
     */
    private struct UrlParams {
        static let location = "location"
        static let radius = "radius"
        static let key = "key"
        static let type = "type"
    }
    
    init(withParser parser: LocationResponseParsable) {
        locationResponseParser = parser
    }
    
    /*
     Search searchNearby
     - location: where to search
     - radius: rounded area in meters to cover
     - type: venue type (bar, restaurant, etc) API Supported types: https://developers.google.com/places/web-service/supported_types
     - callback with results or error message
     */
    func searchNearby(location: CLLocation, radius: Int, type: LocationType, callback: @escaping (Result<[Place]>) -> Void) {
        
        guard isInternetAvailable() == true else {
            callback(Result.error(message: LocationServiceError.internetNotAvailable.rawValue))
            return
        }
        
        guard let url = setupRequest(location: location, radius: radius, type: type) else {
            callback(Result.error(message: LocationServiceError.urlSetup.rawValue))
            return
        }
        
        session.dataTask(with: url) { (data, response, error) in
            // If we get an error from the data task
            guard error == nil else {
                callback(Result.error(message: error?.localizedDescription ?? ""))
                return
            }
            
            // if the response is nil
            guard let responseData = data else {
                callback(Result.error(message: LocationServiceError.noData.rawValue))
                return
            }
            
            self.locationResponseParser.parseLocationSeachResponse(responseData:responseData, callback:callback)
                   
        }.resume()
    }
    

    
    /*
     Sets up the URL object, example:
         https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&type=restaurant&keyword=cruise&key=YOUR_API_KEY
     */
    func setupRequest(location: CLLocation, radius: Int, type: LocationType) -> URL? {
        
        let urlString = Constants.placesURL +
                "\(UrlParams.location)=\(location.coordinate.latitude),\(location.coordinate.longitude)&" +
                "\(UrlParams.radius)=\(radius)&" +
                "\(UrlParams.key)=\(Constants.placesKey)&" +
                "\(UrlParams.type)=\(type.rawValue)"
        return URL(string:urlString)
    }
}

class LocationResponseParser : LocationResponseParsable {
    
    /*
     all the field names we need to capture from response
     */
    private struct ResponseFields {
        static let results = "results"
        static let name = "name"
        static let geometry = "geometry"
        static let location = "location"
        static let lat = "lat"
        static let lng = "lng"
    }
    
    func parseLocationSeachResponse(responseData: Data, callback: @escaping (Result<[Place]>) -> Void) {
        
        // array of model objects
        var places = [Place]()
        
        do {
            // let's try to parse to JSON
            guard let json = try JSONSerialization.jsonObject(with: responseData, options: [])
                as? [String: Any] else {
                    callback(Result.error(message:LocationServiceError.jsonSerialization.rawValue))
                    return
            }
            
            // let's capture the 'results' array from JSON object
            guard let results = json[ResponseFields.results] as? Array<NSDictionary> else {
                callback(Result.error(message:  LocationServiceError.parsing.rawValue))
                return
            }
            
            // Parsing into model object
            // TODO: Use a parsing library like SwiftyJSON or equivalent and
            // make this more resilient.
            
            for result in results {
                
                let name = result[ResponseFields.name] as! String
                var coordinate : CLLocation!
                
                if let geometry = result[ResponseFields.geometry] as? NSDictionary {
                    if let location = geometry[ResponseFields.location] as? NSDictionary {
                        let lat = location[ResponseFields.lat] as! CLLocationDegrees
                        let long = location[ResponseFields.lng] as! CLLocationDegrees
                        coordinate = CLLocation(latitude: lat, longitude: long)
                        let place = Place(name:name, location: coordinate)
                        places.append(place)
                    }
                }
            }
            
            // happy path
            callback(Result.success(response: places))
            
        } catch  {
            // error while parsing
            callback(Result.error(message:LocationServiceError.parsing.rawValue))
            return
        }
    }
}
