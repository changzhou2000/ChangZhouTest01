//
//  MyLocationManager.swift
//  TestSafariExtension01
//
//  Created by Chang Zhou on 2023-07-19.
//

import Foundation
import CoreLocation

class LocationDataManager : NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var enabled: Bool = false
    var altitude: String = ""
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        print("locationManager.requestAlwaysAuthorization()")
        
        if (CLLocationManager.headingAvailable()) {
            print("heading Available")
        } else {
            print("heading not Available")
        }
        
        if (CLLocationManager.locationServicesEnabled()) {
            print("location Available")
            enabled = true
            
            locationManager.startUpdatingLocation()
            
            //            var loc = locationManager.requestLocation()
            //            print(loc)
        } else {
            print("location not Available")
            enabled = false
        }
    }
    
    func getBaroReading() -> String {
        return altitude
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        
        print("newLocation \(newLocation)")
        print("altitude \(newLocation.altitude)")
        print("ellipsoidalAltitude \(newLocation.ellipsoidalAltitude)")
        print("verticalAccuracy \(newLocation.verticalAccuracy)")
        
        altitude = "\(newLocation.altitude)"
    }
}
