//
//  MainTableViewController.swift
//  Connection!
//
//  Created by Avi Cohen on 5/2/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import UIKit

let MainTableViewControllerEstimatedRowHeight = 43.0

class MainTableViewController: UITableViewController {
    
    deinit {
        removeNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = CGFloat(MainTableViewControllerEstimatedRowHeight)
        addNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        // not my bug: the following code is needed because of a bug that doesn't size the cells correctly on first launch
        // http://www.appcoda.com/self-sizing-cells/
        tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    // MARK: Notifications
    
    func addNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didChangePreferredContentSize:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    func removeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    func didChangePreferredContentSize(notification: NSNotification) {
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate

extension MainTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
}

// MARK: - UITableViewDataSource

extension MainTableViewController: UITableViewDataSource {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MainTableViewCell
        cell.actionLabel.text = NSLocalizedString("Invite a contact from your address book by sms", comment: "tap here to invite a contact from your address book by sms")
        //not my bug: although defined in interface builder, when change preferred content size notification is received then font needs to be set again
        cell.actionLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        return cell
    }
    
}