//
//  EnterPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public let PasscodeLockIncorrectPasscodeNotification = "passcode.lock.incorrect.passcode.notification"

struct EnterPasscodeState: PasscodeLockStateType {
    
    let title: String
    let description: String
    var isBiometricAuthAllowed = true
    
    static let incorrectPasscodeAttemptsKey = "incorrectPasscodeAttempts"
    static var incorrectPasscodeAttempts: Int {
        get {
            return UserDefaults.standard.integer(forKey: incorrectPasscodeAttemptsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: incorrectPasscodeAttemptsKey)
        }
    }
    
    private var isNotificationSent = false
    
    init() {
        
        title = localizedStringFor("PasscodeLockEnterTitle", comment: "Enter passcode title")
        description = localizedStringFor("PasscodeLockEnterDescription", comment: "Enter passcode description")
    }
    
    mutating func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType) {
        
        guard let currentPasscode = lock.repository.passcode else {
            return
        }
        
        var incorrectPasscodeAttempts = EnterPasscodeState.incorrectPasscodeAttempts
        if passcode == currentPasscode {
            
            lock.delegate?.passcodeLockDidSucceed(lock)
            incorrectPasscodeAttempts = 0
        } else {
            
            incorrectPasscodeAttempts += 1
            
            if incorrectPasscodeAttempts >= lock.configuration.maximumInccorectPasscodeAttempts {
                
                postNotification()
                incorrectPasscodeAttempts = 0
            }
            
            lock.delegate?.passcodeLockDidFail(lock)
        }
        
        EnterPasscodeState.incorrectPasscodeAttempts = incorrectPasscodeAttempts
    }
    
    fileprivate mutating func postNotification() {
        
        guard !isNotificationSent else { return }
            
        let center = NotificationCenter.default
        
        center.post(name: Notification.Name(rawValue: PasscodeLockIncorrectPasscodeNotification), object: nil)
        
        isNotificationSent = true
    }
}
