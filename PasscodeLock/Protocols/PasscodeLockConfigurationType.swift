//
//  PasscodeLockConfigurationType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import CoreGraphics

public protocol PasscodeLockConfigurationType {
    
    var repository: PasscodeRepositoryType {get}
    var passcodeLength: Int {get}
    var isTouchIDAllowed: Bool {get set}
    var shouldRequestTouchIDImmediately: Bool {get}
    var touchIdReason: String? {get set}
    var maximumInccorectPasscodeAttempts: Int {get}
    var mainWindowLevel: CGFloat { get }
    var passcodeBackWindowLevel: CGFloat { get }
    var passcodeFrontWindowLevel: CGFloat { get }
}

public extension PasscodeLockConfigurationType {
    
    var mainWindowLevel: CGFloat {
        return 1
    }
    
    var passcodeBackWindowLevel: CGFloat {
        return 0
    }
    
    var passcodeFrontWindowLevel: CGFloat {
        return 2
    }
}