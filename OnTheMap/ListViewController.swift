//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Petrik on 24/10/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var studentsTableView: UITableView!
    
    @IBAction func refreshData(sender: AnyObject) {
        loadTableData()
    }

    @IBAction func logout(sender: AnyObject) {
        UdacityClient.sharedInstance().removeSession{ success, errorString in
            dispatch_async(dispatch_get_main_queue()) {
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.displayError(errorString)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTableData()
    }

    func loadTableData() {
        UdacityClient.sharedInstance().getStudentsInformation { studentsInformation, error in
            dispatch_async(dispatch_get_main_queue(), {
                if let studentsInformation = studentsInformation {
                    
                    StudentInformation.studentsInformation = studentsInformation
                    dispatch_async(dispatch_get_main_queue()) {
                        self.studentsTableView.reloadData()
                    }
                } else {
                    self.displayError(error)
                }
            })
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
    
// MARK: TableViewDelegate, TableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformation.studentsInformation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentsInformationTableViewCell") as UITableViewCell!
        
        let student = StudentInformation.studentsInformation[indexPath.row]
        
        cell.textLabel!.text = "\(student.firstName) \(student.lastName)"
        // cell.detailTextLabel!.text = student.mediaURL
        cell.imageView!.image = UIImage(named: "Pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedStudent = StudentInformation.studentsInformation[indexPath.row]
        
        guard let url = selectedStudent.mediaURL else {
            displayError("URL is empty for the selected row.")
            return
        }
        
        let trimmedUrl = url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        guard let nsurl = NSURL(string: trimmedUrl) else {
            displayError("URL is invalid.")
            return
        }
        
        UIApplication.sharedApplication().openURL(nsurl)
    }
    
}
