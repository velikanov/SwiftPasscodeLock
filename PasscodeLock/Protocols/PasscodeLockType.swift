//
//  PasscodeLockType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public protocol PasscodeLockType {
    
    var delegate: PasscodeLockTypeDelegate? {get set}
    var configuration: PasscodeLockConfigurationType {get}
    var repository: PasscodeRepositoryType {get}
    var state: PasscodeLockStateType {get}
    var isTouchIDAllowed: Bool {get}
    
    func addSign(_ sign: String)
    func removeSign()
    func changeStateTo(_ state: PasscodeLockStateType)
    func authenticateWithBiometrics()
}

public protocol PasscodeLockTypeDelegate: class {
    
    func passcodeLockDidSucceed(_ lock: PasscodeLockType)
    func passcodeLockDidFail(_ lock: PasscodeLockType)
    func passcodeLockDidChangeState(_ lock: PasscodeLockType)
    func passcodeLock(_ lock: PasscodeLockType, addedSignAtIndex index: Int)
    func passcodeLock(_ lock: PasscodeLockType, removedSignAtIndex index: Int)
}
