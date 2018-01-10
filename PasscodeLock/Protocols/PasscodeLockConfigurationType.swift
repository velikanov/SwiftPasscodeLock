//
//  PasscodeLockConfigurationType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public protocol PasscodeLockConfigurationType {
    
    var repository: PasscodeRepositoryType {get}
    var passcodeLength: Int {get}
    var isBiometricAuthAllowed: Bool {get set}
    var shouldRequestBiometricAuthImmediately: Bool {get}
    var biometricAuthReason: String? {get set}
    var maximumInccorectPasscodeAttempts: Int {get}
}

// set configuration optionals
public extension PasscodeLockConfigurationType {
    var passcodeLength: Int {
        return 4
    }
    
    var maximumInccorectPasscodeAttempts: Int {
        return -1
    }
}
