//
//  FakePasscodeLockDelegate.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

class FakePasscodeLockDelegate: PasscodeLockTypeDelegate {
    
    func passcodeLockDidSucceed(_ lock: PasscodeLockType) {}
    func passcodeLockDidFail(_ lock: PasscodeLockType) {}
    func passcodeLockDidChangeState(_ lock: PasscodeLockType) {}
    func passcodeLock(_ lock: PasscodeLockType, addedSignAtIndex index: Int) {}
    func passcodeLock(_ lock: PasscodeLockType, removedSignAtIndex index: Int) {}
}
