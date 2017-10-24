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
    var isTouchIDAllowed: Bool {get set}
    var shouldRequestTouchIDImmediately: Bool {get}
    var touchIdReason: String? {get set}
    var maximumInccorectPasscodeAttempts: Int {get}
    var supportedInterfaceOrientations: UIInterfaceOrientationMask {get}
    var shouldAutorotate: Bool {get}
}

// set configuration optionals
extension PasscodeLockConfigurationType {
  var passcodeLength: Int {
    return 4
  }
  
  var maximumInccorectPasscodeAttempts: Int {
    return -1
  }
  
  var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  var shouldAutorotate: Bool {
    return false
  }
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
