//
//  BarsTests.swift
//  BarsTests
//
//  Created by Mariano Latorre on 14/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Bars


class BarsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /*
     Place Model
     */
    func testPlaceModel() {
        
        let location =  CLLocation(latitude: 30, longitude: 40)
        let place = Place(name: "Bar 12", location: location)
        
        XCTAssertEqual(place.name, "Bar 12")
        XCTAssertEqual(place.location.coordinate.latitude, 30)
        XCTAssertEqual(place.location.coordinate.longitude, 40)
    }

    func testPlaceModelEmpty() {
        
        let location = CLLocation(latitude: 0, longitude: 0)
        let place = Place(name: "", location: location)
        
        XCTAssertEqual(place.name, "")
        XCTAssertEqual(place.location.coordinate.latitude, 0)
        XCTAssertEqual(place.location.coordinate.longitude, 0)
    }
    
    /*
     Parser tests
     TODO: implement more edge scenarios, like empty json, malformed json, missing fields, etc
     */
    
    func testParser() {
        
        if let file = Bundle.main.url(forResource: "locationSearchResponse", withExtension: "json") {
            let data = try! Data(contentsOf: file)
            
            let parserExpectation = expectation(description: "Parsing response")
            let locationResponseParser = LocationResponseParser()
            
            locationResponseParser.parseLocationSeachResponse(responseData:data){
                result in
                
                switch(result) {
                    case .error(let message):
                        print(message)
                    case .success(let places):
                        XCTAssertEqual(places[0].name, "Rhythmboat Cruises")
                        XCTAssertEqual(places.count, 4)
                        parserExpectation.fulfill()
                    
                }
            }
            
            waitForExpectations(timeout:3)
        }
    }
    
    func testViewModel() {
        
        let viewModelExpectation = expectation(description: "View Model")
        
        let locationManager = DeviceLocationManagerMock()
        locationManager.latestLocation = CLLocation (latitude: 30, longitude:40)
        
        let locationService = LocationSearchServiceMock()
        
        let fulfillClosure = {
            viewModelExpectation.fulfill()
        }
        
        class BarViewControllerMock : BarViewModelDelegate {
            var viewModel : BarViewModel!
            var showBarsCalled = false
            var showErrorCalled = false
            var fulfillClosure : ((Void) -> ())!
            
            func showBars(){
                showBarsCalled = true
                XCTAssertEqual(viewModel.dataSource?[0].name, "Rhythmboat Cruises")
                XCTAssertEqual(viewModel.dataSource?[0].distance, 13629)
                XCTAssertEqual(viewModel.dataSource?.count, 4)
                fulfillClosure()
            }
            func showError(message: String) {
                showErrorCalled = true
            }
        }
        
        let barViewController = BarViewControllerMock()
        barViewController.fulfillClosure = fulfillClosure
        
        
        barViewController.viewModel = BarViewModel(withDelegate:barViewController,
                                          locationManager:locationManager,
                                          locationSearchService: locationService)
        
        
        waitForExpectations(timeout:3)
    }
    
}
