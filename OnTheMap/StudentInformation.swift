//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Petrik on 24/10/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var uniqueKey: String!
    var firstName: String!
    var lastName: String!
    var mapString: String!
    var mediaURL: String!
    var latitude: Float64
    var longitude: Float64
    
    init(dictionary: [String : AnyObject]) {
        uniqueKey = dictionary["uniqueKey"] as! String
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        mapString = dictionary["mapString"] as! String
        mediaURL = dictionary["mediaURL"] as! String
        latitude = dictionary["latitude"] as! Float64
        longitude = dictionary["longitude"] as! Float64
    }
    
    static func studentsInformationFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        
        var studentsInformation = [StudentInformation]()
        
        for result in results {
            studentsInformation.append(StudentInformation(dictionary: result))
        }
        
        return studentsInformation
    }
}