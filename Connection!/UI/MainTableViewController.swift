//
//  MainTableViewController.swift
//  Connection!
//
//  Created by Avi Cohen on 5/2/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import UIKit
import AddressBookUI
import MessageUI

let MainTableViewControllerEstimatedRowHeight = 43.0

class MainTableViewController: UITableViewController {
    
    private let labels = [NSLocalizedString("Invite a contact from your address book by sms", comment: "tap here to invite a contact from your address book by sms")]
    private let connections = Connections.sharedInstance
    
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
    
    // MARK: SMS
    
    func sendInvitation(connection: Connection) {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            let title = "Simulator"
            let message = "sending SMS success or fail?"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            var actionTitle = "Success"
            var action = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(action)
            actionTitle = "Fail"
            action = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default){ [weak self] action -> Void in
                self!.deleteLastConnection()
            }
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
            #else
            if MFMessageComposeViewController.canSendText() {
                let messageVC = MFMessageComposeViewController()
                messageVC.messageComposeDelegate = self
                messageVC.recipients = [connection.phone]
                let bodyFormat = NSLocalizedString("Please accept my invitation by entering in Connection!: %@", comment: "Please accept my invitation by entering in Connection!: {verification digits}")
                messageVC.body = NSString(format: bodyFormat, connection.vn) as String
                self.presentViewController(messageVC, animated: true, completion: nil)
            }
            else {
                Log.fail(functionName: __FUNCTION__, message: "Can't send the message since the user hasn't setup the Messages app yet.")
                deleteLastConnection()
                let title = NSLocalizedString("Message Composing", comment:"An alert title called: Message Composing ")
                let message = NSLocalizedString("Please setup the Messages app and try again.", comment:"Please setup the Messages app and try again.")
                let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let actionTitle = NSLocalizedString("OK", comment: "OK")
                alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        #endif
    }
    
    // MARK: Connections
    
    func deleteLastConnection() {
        connections.deleteLastConnection(
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
        })
        
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
                    // not my bug: same as above reason
                    let phone: NSString = ABMultiValueCopyValueAtIndex(phones, ABMultiValueGetIndexForIdentifier(phones, identifier)).takeRetainedValue() as! NSString
                    self!.connections.invite(name: name as String, phone: phone as String,
                        success: { [weak self] (connection) -> () in
                            self!.sendInvitation(connection)
                        },
                        fail: { [weak self] (error) -> () in
                            let alert = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: UIAlertControllerStyle.Alert)
                            let title = NSLocalizedString("OK", comment: "OK")
                            alert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: nil))
                            self!.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
}

extension MainTableViewController: MFMessageComposeViewControllerDelegate {
 
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch result.value {
        case MessageComposeResultSent.value:
            Log.success(functionName: __FUNCTION__, message: "SMS message was sent successfuly")
        case MessageComposeResultCancelled.value:
            Log.fail(functionName: __FUNCTION__, message: "SMS message was cancelled")
            deleteLastConnection()
        case MessageComposeResultFailed.value:
            Log.fail(functionName: __FUNCTION__, message: "SMS message sent failed")
            deleteLastConnection()
        default:
            Log.fail(functionName: __FUNCTION__, message: "SMS message result is \(result.value)")
            deleteLastConnection()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
