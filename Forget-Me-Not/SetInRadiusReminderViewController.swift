//
//  SetInRadiusReminderViewController.swift
//  Forget-Me-Not
//
//  Created by Lukas Carvajal on 10/16/15.
//  Copyright © 2015 Lukas Carvajal. All rights reserved.
//

import UIKit
import MapKit

class SetInRadiusReminderViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {

    var notificationCircle = MKCircle()
    
    @IBOutlet weak var reminderTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timerPickerView: UIPickerView!
    
    override func viewWillAppear(animated: Bool) {
        titleTextField.delegate = self
        titleTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(animated: Bool) {
        titleTextField.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveReminder(sender: AnyObject) {
        if reminderTypeSegmentedControl.selectedSegmentIndex == 0 {
            // Create a 'When I leave' reminder.
            let reminder = UILocalNotification()
            reminder.alertBody = titleTextField.text
            reminder.region = CLCircularRegion(center:notificationCircle.coordinate , radius: notificationCircle.radius, identifier: "whenILeave")
            UIApplication.sharedApplication().scheduleLocalNotification(reminder)
            
            // Alert user, reminder has been set.
            let reminderSetAlert = UIAlertView.init(title: "Reminder Set!", message: "A reminder will go off when you leave the area.", delegate: self, cancelButtonTitle: "Ok")
            reminderSetAlert.show()
            
            // Go back to map.
            dismissViewControllerAnimated(true, completion: nil)
        }
        else if reminderTypeSegmentedControl.selectedSegmentIndex == 1 {
            // 'When I haven't left' reminder.
        }
    }
    @IBAction func cancelSetReminder(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func reminderTypeChanged(sender: AnyObject) {
        if reminderTypeSegmentedControl.selectedSegmentIndex == 0 {
            // 'When I leave' reminder requires no timer.
            timerPickerView.hidden = true
            titleTextField.becomeFirstResponder()
        }
        else if reminderTypeSegmentedControl.selectedSegmentIndex == 1 {
            // 'When I haven't left' reminder requires a timer to be set.
            timerPickerView.hidden = false
            titleTextField.resignFirstResponder()
        }
    }
}
