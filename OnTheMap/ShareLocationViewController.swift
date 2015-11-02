//
//  ShareLocationViewController.swift
//  OnTheMap
//
//  Created by Petrik on 26/10/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import UIKit
import MapKit

class ShareLocationViewController: UIViewController, UITextFieldDelegate {

    var studentPin: StudentPin!
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func displayMessage(message: String?, okAction: ((UIAlertAction) -> Void)?) {
        let myAlert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: okAction))
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func validateURLfromTextField(url: String) -> Bool {
        if url == "Enter a Link to Share Here" || url == "" {
            displayMessage("You must type an url", okAction: nil)
            return false
        }
        
        if !(url.hasPrefix("http://") || url.hasPrefix("https://")) {
            displayMessage("Your url must start with http(s)://", okAction: nil)
            return false
        }
        return true
    }
    
    @IBAction func previewURLButtonPressed(sender: AnyObject) {
        let url = urlTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let isValidUrl = validateURLfromTextField(url)
        
        if isValidUrl {
            guard let nsurl = NSURL(string: url) else {
                displayMessage("URL is invalid.", okAction: nil)
                return
            }
            
            UIApplication.sharedApplication().openURL(nsurl)
        }
    }

    func completePosting() {
        displayMessage("Your information has been successfully posted!") { (alertAction) in
            dispatch_async(dispatch_get_main_queue(), {
                self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
            })
        }
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        let url = urlTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let isValidUrl = validateURLfromTextField(url)
        
        if isValidUrl {
            guard let _ = NSURL(string: url) else {
                displayMessage("URL is invalid.", okAction: nil)
                return
            }
            studentPin.url = urlTextField!.text
            
            activityIndicator.startAnimating()
            UdacityClient.sharedInstance().postStudentLocation(studentPin) { success, errorString in
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()
                    if success {
                        self.completePosting()
                    } else {
                        self.displayMessage(errorString, okAction: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        presentingViewController?.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        locationNameLabel.text = studentPin.locationName
        
        showUserPin()
    }

    func showUserPin() {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        let lat = CLLocationDegrees(studentPin.lat)
        let long = CLLocationDegrees(studentPin.long)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    // MARK: - TextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.text == "Enter a Link to Share Here" {
            textField.text = ""
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
