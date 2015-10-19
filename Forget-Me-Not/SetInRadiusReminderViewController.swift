//
//  SetInRadiusReminderViewController.swift
//  Forget-Me-Not
//
//  Created by Lukas Carvajal on 10/16/15.
//  Copyright © 2015 Lukas Carvajal. All rights reserved.
//

import UIKit
import MapKit

class SetInRadiusReminderViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    var notificationCircle = MKCircle()
    var numbersArray = NSMutableArray()
    
    @IBOutlet weak var reminderTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timerPickerView: UIPickerView!
    
    override func viewWillAppear(animated: Bool) {
        titleTextField.delegate = self
        titleTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerPickerView.dataSource = self
        timerPickerView.delegate = self
        
        numbersArray.addObject("title")
        for index in 0...59 {
            numbersArray.addObject(index)
        }
        // First row is for hour/minute titles.
        timerPickerView.selectRow(1, inComponent: 0, animated: false)
        timerPickerView.selectRow(1, inComponent: 1, animated: false)
    }

    override func viewWillDisappear(animated: Bool) {
        titleTextField.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Reminder Actions
    
    @IBAction func saveReminder(sender: AnyObject) {
        if reminderTypeSegmentedControl.selectedSegmentIndex == 0 {
            // Create a 'When I leave' reminder.
            let reminder = UILocalNotification()
            reminder.alertBody = titleTextField.text
            reminder.region = CLCircularRegion(center:notificationCircle.coordinate , radius: notificationCircle.radius, identifier: "whenILeave")
            UIApplication.sharedApplication().scheduleLocalNotification(reminder)
            
            // Alert user, reminder has been set.
            let reminderSetAlert = UIAlertView.init(title: "Reminder Set!", message: "You'll receive a notification when you leave the area.", delegate: self, cancelButtonTitle: "Ok")
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
            titleTextField.returnKeyType = UIReturnKeyType.Go
            titleTextField.becomeFirstResponder()
            titleTextField.reloadInputViews()
        }
        else if reminderTypeSegmentedControl.selectedSegmentIndex == 1 {
            // 'When I haven't left' reminder requires a timer to be set.
            timerPickerView.hidden = false
            titleTextField.returnKeyType = UIReturnKeyType.Done
            titleTextField.resignFirstResponder()
        }
    }
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Keyboard actions change based on reminder.
        if reminderTypeSegmentedControl.selectedSegmentIndex == 0 {
            saveReminder(self)
            return true
        }
        else if reminderTypeSegmentedControl.selectedSegmentIndex == 1 {
            titleTextField.resignFirstResponder()
            return true
        }
        return false
    }
    
    // MARK: - PickerView Data Source and Delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            // Hours.
            return 25
        }
        else if component == 1 {
            // Minutes.
            return 61
        }
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            if component == 0 {
                return "hours"
            }
            else {
                return "minutes"
            }
        }
        return "\(numbersArray[row])"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            timerPickerView.selectRow(1, inComponent: component, animated: true)
        }
    }
}
