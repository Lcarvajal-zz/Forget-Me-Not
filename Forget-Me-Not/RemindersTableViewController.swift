//
//  RemindersTableViewController.swift
//  Forget-Me-Not
//
//  Created by Lukas Carvajal on 10/16/15.
//  Copyright © 2015 Lukas Carvajal. All rights reserved.
//

import UIKit

class RemindersTableViewController: UITableViewController {

    var remindersArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCurrentReminders()
        
        // Tableview UI.
        tableView.registerNib(UINib.init(nibName: "ReminderTableViewCell", bundle: nil), forCellReuseIdentifier: "ReminderCell")
        let tableFooterView = UIView()
        tableFooterView.backgroundColor = UIColor.blueColor()
        tableView.tableFooterView = tableFooterView
        
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.allowsSelection = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func loadCurrentReminders() {
        remindersArray = UIApplication.sharedApplication().scheduledLocalNotifications!
        
        if remindersArray.count == 0 {
            let noRemindersView = NSBundle.mainBundle().loadNibNamed("NoRemindersView", owner: self, options: nil)
            tableView.backgroundView =  noRemindersView[0] as? UIView
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // Delete reminder selected.
            let reminderToDelete = remindersArray[indexPath.row] as! UILocalNotification
            UIApplication.sharedApplication().cancelLocalNotification(reminderToDelete)
            loadCurrentReminders()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindersArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as! ReminderTableViewCell
        let reminder = remindersArray[indexPath.row] as! UILocalNotification
        cell.reminderLabel.text = reminder.alertBody
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
}
