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
            if let errorString = errorString {
                self.errorMessageLabel.text = errorString
            }
        })
    }
    
    @IBAction func doLogin(sender: AnyObject) {
        guard let email = emailTextField?.text where emailTextField.text != "" else {
            print("empty email")
            return
        }
        
        guard let password = passwordTextField?.text where passwordTextField.text != "" else {
            print("empty password")
            return
        }
        
        UdacityClient.sharedInstance().createSessionForCredentials(email, password: password) { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                if let errorString = errorString {
                    self.errorMessageLabel.text = errorString
                }
            })
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

