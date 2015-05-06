//
//  MainTableViewController.swift
//  Connection!
//
//  Created by Avi Cohen on 5/2/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import UIKit
import AddressBookUI


let MainTableViewControllerEstimatedRowHeight = 43.0

class MainTableViewController: UITableViewController {
    
    private let labels = [NSLocalizedString("Invite a contact from your address book by sms", comment: "tap here to invite a contact from your address book by sms")]
    
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
    
    // MARK: Address Book

    func showAddressBookForInvitation() {
        let picker = ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        picker.displayedProperties = [Int(kABPersonPhoneProperty)];
        picker.predicateForEnablingPerson = NSPredicate(format: "phoneNumbers.@count > 0")
        presentViewController(picker, animated: false, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension MainTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let cell = cell {
            switch cell.tag {
            case 0:
                showAddressBookForInvitation()
            default:
                showAddressBookForInvitation()
            }
        }
    }
    
}

// MARK: - UITableViewDataSource

extension MainTableViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.indexAtPosition(indexPath.length - 1)
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MainTableViewCell
        cell.actionLabel.text = labels[index]
        // not my bug: although defined in interface builder, when change preferred content size notification is received then font needs to be set again
        cell.actionLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        cell.tag = index
        return cell
    }
    
}

// MARK: - ABPeoplePickerNavigationControllerDelegate

extension MainTableViewController: ABPeoplePickerNavigationControllerDelegate {
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        peoplePicker.dismissViewControllerAnimated(false) { [weak self] in
            let vc = self!.storyboard!.instantiateViewControllerWithIdentifier("ProgressViewController") as! ProgressViewController
            vc.snapshotViewContent = self!.view.snapshotViewAfterScreenUpdates(false)
            self!.presentViewController(vc, animated: false) {
                // not my bug: swift can't cast strait from CFString to String, so a casting from CFString to NSString is needed in the middle
                let name: NSString = ABRecordCopyCompositeName(person).takeRetainedValue()
                if(property == kABPersonPhoneProperty) {
                    let phones: ABMultiValueRef = ABRecordCopyValue(person, property).takeRetainedValue()
                    // not my bug: swift can't cast strait from CFString to String, so a casting from CFString to NSString is needed in the middle
                    let phone: NSString = ABMultiValueCopyValueAtIndex(phones, ABMultiValueGetIndexForIdentifier(phones, identifier)).takeRetainedValue() as! NSString
                }
            }
        }
    }
    
}


