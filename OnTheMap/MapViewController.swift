//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Petrik on 24/10/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadAnnotations()
    }

    @IBAction func refreshDataBarButtonPressed(sender: AnyObject) {
        removeAnnotations()
        loadAnnotations()
    }
    
    
    @IBAction func logoutBarButtonPressed(sender: AnyObject) {
        UdacityClient.sharedInstance().removeSession{ success, errorString in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.displayError(errorString)
                }
            })
        }
    }
    
    func loadAnnotations() {
        UdacityClient.sharedInstance().getStudentsInformation { studentsInformation, error in
            if let studentsInformation = studentsInformation {
                
                StudentInformation.studentsInformation = studentsInformation
                
                var annotations = [MKPointAnnotation]()
                
                for student in studentsInformation {
                    let lat = CLLocationDegrees(student.latitude)
                    let long = CLLocationDegrees(student.longitude)
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(student.firstName) \(student.lastName)"
                    annotation.subtitle = student.mediaURL
                    
                    annotations.append(annotation)
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addAnnotations(annotations)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayError(error)
                }
            }
        }
    }
    
    func removeAnnotations() {
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }
    
    func refreshAnnotations() {
        removeAnnotations()
        loadAnnotations()
    }
    
    func displayError(errorString: String?) {
        guard let errorString = errorString else {
            return
        }
        
        let myAlert = UIAlertController(title: errorString, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    // MARK: - MapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseMapId = "MapId"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseMapId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseMapId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            guard let url = view.annotation?.subtitle else {
                displayError("URL is empty for the selected point")
                return
            }
            
            UIApplication.sharedApplication().openURL(NSURL(string: url!)!)
        }
    }

}
