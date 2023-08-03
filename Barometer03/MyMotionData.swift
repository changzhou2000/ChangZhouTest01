//
//  MyMotionData.swift
//  TestSafariExtension01
//
//  Created by Chang Zhou on 2023-07-22.
//

import Foundation
import CoreMotion

class MyCoreMotionHelper : NSObject {
    
    var enabled: Bool = false
    var altitude: String = ""
    var baroData: Double = 0.0
    let queue = OperationQueue()
    let altimeter: CMAltimeter = CMAltimeter()
    
    override init() {
        super.init()
        
        if (CMAltimeter.isRelativeAltitudeAvailable()) {
            print("motion data altitude available")
            enabled = true
            
            altimeter.startRelativeAltitudeUpdates(to: queue) { [weak self] data, error in
                guard let self = self else { return }
                if let error = error {
                    print("error \(error)")
                    self.altimeter.stopRelativeAltitudeUpdates()
                    self.enabled = false
                    return
                }
                guard let data = data else { return }
                
                altitude = "\(data.pressure.intValue) kilopascals"
                baroData = data.pressure.doubleValue
            }
        } else {
            print("motion data altitude not available")
            enabled = false
        }
    }
    
    func getBaroData() -> Double {
        return baroData
    }
    
    func getBaroReading() -> String {
        return altitude
    }
}
