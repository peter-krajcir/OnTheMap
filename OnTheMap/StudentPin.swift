//
//  StudentPin.swift
//  OnTheMap
//
//  Created by Petrik on 26/10/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import Foundation

class StudentPin {
    var lat: Double = 0.0
    var long: Double = 0.0
    var locationName: String?
    var url: String?
    
    init(lat: Double, long: Double, locationName: String?) {
        self.lat = lat
        self.long = long
        self.locationName = locationName
    }
}