//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Petrik on 23/10/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import UIKit

class UdacityClient: NSObject {
    
    /* Static Constants */
    
    static let ParseApiKey = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let RestApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    static let SecureUdacityUrl = "https://www.udacity.com/api/"
    static let SecureParseUrl = "https://api.parse.com/1/classes/StudentLocation"
    
    static let UdacitySessionMethod = "session"
    static let UdacityPublicUserDataMethod = "users"
    
    static let ParseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let ParseRestApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    static let StudentsInformationApiParams = ["limit": 100, "order": "-updatedAt"]
    
    var session: NSURLSession
    
    var accountKey: String!
    var accountSessionId: String!
    var firstName: String!
    var lastName: String!
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func createSessionForCredentials(username: String, password: String, callback: (success: Bool, errorString: String?) -> Void ) {
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityClient.SecureUdacityUrl + UdacityClient.UdacitySessionMethod)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                callback(success: false, errorString: "Login Failed (Session Id Data Error)")
                return
            }
 
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(newData)'")
                callback(success: false, errorString: "Login Failed (Wrong response from server")
                return
            }
            
            guard let statusCode = parsedResult["status"] where statusCode == nil else {
                let errorMessage = parsedResult["error"] as? String
                print("error: \(errorMessage)")
                callback(success: false, errorString: errorMessage)
                return
            }
            
            guard let accountDict = parsedResult["account"] as? [String: AnyObject] else {
                print("Can't find key 'account' in \(parsedResult)")
                callback(success: false, errorString: "Login Failed (Wrong response from server")
                return
            }
            
            guard let accountKey = accountDict["key"] as? String else {
                print("Can't find key 'account[key]' in \(parsedResult)")
                callback(success: false, errorString: "Login Failed (Wrong response from server")
                return
            }
            
            self.accountKey = accountKey
            
            guard let sessionDict = parsedResult["session"] as? [String: AnyObject] else {
                print("Can't find key 'session' in \(parsedResult)")
                callback(success: false, errorString: "Login Failed (Wrong response from server")
                return
            }
            
            guard let sessionId = sessionDict["id"] as? String else {
                print("Can't find key 'session[id]' in \(parsedResult)")
                callback(success: false, errorString: "Login Failed (Wrong response from server")
                return
            }
            
            self.accountSessionId = sessionId
            
            callback(success: true, errorString: nil)
        }
        
        task.resume()
    }
    
    func postStudentLocation(studentPin: StudentPin, callback: (success: Bool, errorString: String?) -> Void ) {
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityClient.SecureParseUrl)!)
        request.HTTPMethod = "POST"
        request.addValue(UdacityClient.ParseApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityClient.ParseRestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.HTTPBody = "{\"uniqueKey\": \"\(accountKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(studentPin.locationName!)\", \"mediaURL\": \"\(studentPin.url!)\",\"latitude\": \(studentPin.lat), \"longitude\": \(studentPin.long)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                callback(success: false, errorString: "Submitting failed \(error?.description)")
                return
            }
            
            guard let data = data else {
                callback(success: false, errorString: "Submitting failed (No response from server)")
                return
            }
                        
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                callback(success: false, errorString: "Submitting failed (Wrong response from server")
                return
            }
            
            guard let errorMessage = parsedResult["error"] where errorMessage == nil else {
                let errorMessage = parsedResult["error"] as! String
                callback(success: false, errorString: "Submitting failed \(errorMessage)")
                return
            }
            
           guard let _ = parsedResult["objectId"] as? String else {
                print("Can't find key 'objectId' in \(parsedResult)")
                callback(success: false, errorString: "Submitting Failed (Wrong response from server")
                return
            }
            
            callback(success: true, errorString: nil)
        }
        
        task.resume()
    }
    
    func getPublicUserData(accountKey: String!, callback: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityClient.SecureUdacityUrl + UdacityClient.UdacityPublicUserDataMethod + "/" + accountKey)!)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                callback(success: false, errorString: "Getting Public User Data failed \(accountKey)")
                return
            }
            
            guard let data = data else {
                print("Data are empty")
                callback(success: false, errorString: "Data are empty")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(newData)'")
                callback(success: false, errorString: "Public User Data (Wrong response from server")
                return
            }
            
            guard let user = parsedResult["user"] as? [String: AnyObject] else {
                print("Can't find key 'user' in \(parsedResult)")
                callback(success: false, errorString: "Public User Data (Wrong response from server")
                return
            }
            
            guard let firstName = user["first_name"] as? String, lastName = user["last_name"] as? String else {
                print("Can't find key 'first_name' or 'last_name' in \(user)")
                callback(success: false, errorString: "Public User Data (Wrong response from server")
                return
            }
            
            self.firstName = firstName
            self.lastName = lastName
            
            callback(success: true, errorString: nil)
            
        }
        
        task.resume()
    }
    
    func removeSession( callback: (success: Bool, errorString: String?) -> Void ) {
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityClient.SecureUdacityUrl + UdacityClient.UdacitySessionMethod)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in (sharedCookieStorage.cookies as [NSHTTPCookie]?)! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                callback(success: false, errorString: "Logout Failed (Session Id Data Error)")
                return
            }
            
            guard let data = data else {
                print("Data are empty")
                callback(success: false, errorString: "Data are empty")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(newData)'")
                callback(success: false, errorString: "Logout Failed (Wrong response from server")
                return
            }
            
            guard let _ = parsedResult["session"] as? [String: AnyObject] else {
                print("Can't find key 'session' in \(parsedResult)")
                callback(success: false, errorString: "Logout Failed (Wrong response from server")
                return
            }
            
            self.accountKey = ""
            self.accountSessionId = ""
            
            callback(success: true, errorString: nil)
            
        }
        
        task.resume()
    }
    
    func getStudentsInformation(callback: (studentsInformation: [StudentInformation]?, errorString: String?) -> Void ) {
        let url = UdacityClient.SecureParseUrl + escapedParameters(UdacityClient.StudentsInformationApiParams)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.addValue(UdacityClient.ParseApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityClient.ParseRestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            
            guard let data = data else {
                print("Data are empty")
                callback(studentsInformation: nil, errorString: "Data are empty")
                return
            }
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String: AnyObject]] else {
                print("Can't find key 'results' in \(parsedResult)")
                return
            }
            
            let studentsInformation = StudentInformation.studentsInformationFromResults(results)
            
            callback(studentsInformation: studentsInformation, errorString: nil)
        }
        
        task.resume()
    }
    
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}
