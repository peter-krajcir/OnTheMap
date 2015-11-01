//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Petrik on 24/10/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var studentsInformation: [StudentInformation] = [StudentInformation]()
    
    @IBOutlet weak var studentsTableView: UITableView!
    
    @IBAction func refreshData(sender: AnyObject) {
        loadTableData()
    }

    @IBAction func logout(sender: AnyObject) {
        UdacityClient.sharedInstance().removeSession{ success, errorString in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print(errorString)
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
                    self.studentsInformation = studentsInformation
                    dispatch_async(dispatch_get_main_queue()) {
                        self.studentsTableView.reloadData()
                    }
                } else {
                    print(error)
                }
            })
        }
    }
    
// MARK: TableViewDelegate, TableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsInformation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentsInformationTableViewCell") as UITableViewCell!
        
        let student = studentsInformation[indexPath.row]
        
        cell.textLabel!.text = "\(student.firstName) \(student.lastName)"
        // cell.detailTextLabel!.text = student.mediaURL
        cell.imageView!.image = UIImage(named: "Pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedStudent = studentsInformation[indexPath.row]
        
        guard let url = selectedStudent.mediaURL else {
            print("empty url")
            return
        }
        
        let trimmedUrl = url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        guard let nsurl = NSURL(string: trimmedUrl) else {
            print("invalid url")
            return
        }
        
        UIApplication.sharedApplication().openURL(nsurl)
    }
    
}
