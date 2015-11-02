//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Petrik on 23/10/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signUpButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }

    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.errorMessageLabel.text = ""
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }

    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            let myAlert = UIAlertController(title: errorString, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(myAlert, animated: true, completion: nil)
            
            if let errorString = errorString {
                self.errorMessageLabel.text = errorString
            }
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(CGPoint: CGPointMake(self.errorMessageLabel.center.x - 10, self.errorMessageLabel.center.y))
            animation.toValue = NSValue(CGPoint: CGPointMake(self.errorMessageLabel.center.x + 10, self.errorMessageLabel.center.y))
            self.errorMessageLabel.layer.addAnimation(animation, forKey: "position")
        })
    }
    
    @IBAction func doLogin(sender: AnyObject) {
        guard let email = emailTextField?.text where emailTextField.text != "" else {
            self.displayError("Email field can't be empty")
            return
        }
        
        guard let password = passwordTextField?.text where passwordTextField.text != "" else {
            self.displayError("Password field can't be empty")
            return
        }
        activityIndicator.startAnimating()
        UdacityClient.sharedInstance().createSessionForCredentials(email, password: password) { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
            })
            if let errorString = errorString {
                self.displayError(errorString)
                return
            }
            if success {
                UdacityClient.sharedInstance().getPublicUserData(UdacityClient.sharedInstance().accountKey) { (success, errorString) in
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayError(errorString)
                    }
                }
            } else {
                self.displayError(errorString)
            }
        }
    }

}

