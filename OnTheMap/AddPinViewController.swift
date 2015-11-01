//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by Petrik on 25/10/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import UIKit
import CoreLocation

class AddPinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var geocoder: CLGeocoder!
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnMapButtonPressed(sender: AnyObject) {
        let location = locationTextField.text!
        if location != "" {
            activityIndicator.startAnimating()
            geocoder.geocodeAddressString(location) { (placemarks, error) in
                self.activityIndicator.stopAnimating()
                if error != nil {
                    self.displayError(error?.localizedDescription)
                    return
                }
                
                guard let placemarks = placemarks else {
                    self.displayError("Couldn't recognize the address!")
                    return
                }
                let placemark = placemarks[0]
                let lat = placemark.location!.coordinate.latitude
                let long = placemark.location!.coordinate.longitude
                let country = placemark.country
                let state = placemark.administrativeArea
                let city = placemark.locality
                let locationName: String
                if country != nil && city != nil {
                    locationName = city! + ", " + (state != nil && state! != city! && state! != country! ? state! + ", " : "") + country!
                } else {
                    locationName = ""
                }
                
                let studentPin = StudentPin(lat: lat, long: long, locationName: locationName)
                
                self.performSegueWithIdentifier("shareURLSegue", sender: studentPin)
            }
        }
    }
    
    func displayError(errorString: String?) {
        guard let errorString = errorString else {
            return
        }
        
        let myAlert = UIAlertController(title: errorString, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        geocoder = CLGeocoder()
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "shareURLSegue" {
            let shareLocationController = segue.destinationViewController as! ShareLocationViewController
            let studentPin = sender as! StudentPin
            shareLocationController.studentPin = studentPin
        }
    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.text == "Enter Your Location Here" {
            textField.text = ""
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
