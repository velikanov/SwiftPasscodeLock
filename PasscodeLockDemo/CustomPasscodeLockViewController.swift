//
//  CustomPasscodeLockViewController.swift
//  PasscodeLock
//
//  Adds:
//  * Exponential backoff after a failed PIN entry
//
//  Created by Chris Ziogas on 10/06/16.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit
import PasscodeLock

class CustomPasscodeLockViewController: PasscodeLockViewController {
    
    @IBOutlet var buttons: [PasscodeSignButton] = [PasscodeSignButton]()
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    var UserDefaultsPINExponentialBackoffName = "PasscodeLock.PINExponentialBackoffDict"
    
    // is the max time a user can be blocked
    let exponentialBackoffMaxTime = 60.0 * 60.0 // secs * mins
    
    // is the Base for exponential backoff
    var exponentialBackoffTimeBase = 2.0
    
    // this is actually the number of retries
    var exponentialBackoffTimePower = 0.0
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // check if user is blocked from entering a PIN because
        // of wrong attemps and exponential backoff
        let now = NSDate()
        
        if let backoffDict = defaults.objectForKey(UserDefaultsPINExponentialBackoffName) as? [String: AnyObject],
            
            // get until what time user is blocked
            let backoffUntilDate = backoffDict["until"] as? NSDate
            where backoffUntilDate.compare(now) == NSComparisonResult.OrderedDescending,
            
            // get number of wrong retries, so as we can calculate the backoff time
            // on the next wrong attempt
            let backoffNumberOfRetries = backoffDict["numberOfRetries"] as? Double
        {
            // set exponentialBackoffTimePower for next failed attempt
            exponentialBackoffTimePower = backoffNumberOfRetries
            
            // stop user interactions
            togglePinEntry(false)
            
            // unblock user input, after backoffUntilDate
            unblockUserInputAfterSeconds(backoffUntilDate.timeIntervalSinceNow)
        
        } else if defaults.boolForKey(UserDefaultsIncorrectPasscodeAttemptsReachedName) {
            // TODO: handle how user will continue
            showLockedAlert()
        }
    }
    
    override func passcodeLock(lock: PasscodeLockType, addedSignAtIndex index: Int) {
        super.passcodeLock(lock, addedSignAtIndex: index)
        
        deleteSignButton?.hidden = false
    }
    
    override func passcodeLock(lock: PasscodeLockType, removedSignAtIndex index: Int) {
        super.passcodeLock(lock, removedSignAtIndex: index)
        
        if index == 0 {
            deleteSignButton?.hidden = true
        }
    }
    
    // MARK: - PasscodeLockDelegate
    override func passcodeLockDidSucceed(lock: PasscodeLockType) {
        super.passcodeLockDidSucceed(lock)
        
        // hide delete button
        deleteSignButton?.hidden = true
        
        // reset exponential backoff time
        exponentialBackoffTimePower = 0.0
        defaults.removeObjectForKey(UserDefaultsPINExponentialBackoffName)
        
        // start user interactions
        self.togglePinEntry(true)
    }
    
    override func passcodeLockDidFail(lock: PasscodeLockType) {
        super.passcodeLockDidFail(lock)
        
        // hide delete button
        deleteSignButton?.hidden = true
        
        // stop user interactions
        togglePinEntry(false)
        
        // using exponential backoff re-enable user-interactions after some seconds
        let backoffTime = pow(exponentialBackoffTimeBase, exponentialBackoffTimePower)
        
        // persist value in NSUserDefaults so as if user force-quits the app
        // we know that user was blocked
        let backoffUntil = NSDate().dateByAddingTimeInterval(backoffTime)
        let backoffDict = [
            "until": backoffUntil,
            "numberOfRetries": exponentialBackoffTimePower
        ]
        defaults.setObject(backoffDict, forKey: UserDefaultsPINExponentialBackoffName)
        
        // unblock user input
        unblockUserInputAfterSeconds(backoffTime)
    }
    
    func unblockUserInputAfterSeconds(seconds: Double) {
        
        delay(min(seconds, exponentialBackoffMaxTime)) {
            
            // start user interactions
            self.togglePinEntry(true)
            
            self.exponentialBackoffTimePower += 1.0
        }
    }
    
    func togglePinEntry(enabled: Bool) {
        
        // toggle buttons enabled
        for button in buttons {
            button.enabled = enabled
            
            // make the button transparent when disabled
            button.alpha = enabled ? 1.0 : 0.5
        }
        
        // toggle user interactions, which will limit more things
        // at the moment we prefer to continue allowing login with TouchID
        // self.view.userInteractionEnabled = enabled
    }
    
    // for demo purposes
    func showLockedAlert() {
        
        // stop user interactions
        togglePinEntry(false)
        
        let alertController = UIAlertController(title: "You have been locked out", message: "", preferredStyle: .Alert)
        
        let giveAccessAction = UIAlertAction(title: "Let me in", style: .Default, handler: { [weak self] action in
        
            // unset that incorect password attempts has been reached
            self?.defaults.removeObjectForKey(UserDefaultsIncorrectPasscodeAttemptsReachedName)
            
            // start user interactions
            self?.togglePinEntry(true)
        })
        alertController.addAction(giveAccessAction)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}