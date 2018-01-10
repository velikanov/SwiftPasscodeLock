//
//  PasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import LocalAuthentication

open class PasscodeLock: PasscodeLockType {
    
    open weak var delegate: PasscodeLockTypeDelegate?
    open let configuration: PasscodeLockConfigurationType
    
    open var repository: PasscodeRepositoryType {
        return configuration.repository
    }
    
    open var state: PasscodeLockStateType {
        return lockState
    }
    
    open var isBiometricAuthAllowed: Bool {
        return isBiometricAuthEnabled() && configuration.isBiometricAuthAllowed && lockState.isBiometricAuthAllowed
    }
    
    fileprivate var lockState: PasscodeLockStateType
    fileprivate lazy var passcode = [String]()
    
    public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType) {
        
        precondition(configuration.passcodeLength > 0, "Passcode length sould be greather than zero.")
        
        self.lockState = state
        self.configuration = configuration
    }
    
    open func addSign(_ sign: String) {
        
        passcode.append(sign)
        delegate?.passcodeLock(self, addedSignAtIndex: passcode.count - 1)
        
        if passcode.count >= configuration.passcodeLength {
            
            // handles "requires exclusive access" error at Swift 4
            var lockStateCopy = lockState
            lockStateCopy.acceptPasscode(passcode, fromLock: self)
            passcode.removeAll(keepingCapacity: true)
        }
    }
    
    open func removeSign() {
        
        guard passcode.count > 0 else { return }
        
        passcode.removeLast()
        delegate?.passcodeLock(self, removedSignAtIndex: passcode.count)
    }
    
    open func changeStateTo(_ state: PasscodeLockStateType) {
        
        lockState = state
        delegate?.passcodeLockDidChangeState(self)
    }
    
    open func authenticateWithBiometrics() {
        
        guard isBiometricAuthAllowed else { return }
        
        let context = LAContext()
        let reason: String
        if let configReason = configuration.biometricAuthReason {
            reason = configReason
        } else {
            if #available(iOS 11, *) {
                switch(context.biometryType) {
                case .touchID:
                    reason = localizedStringFor("PasscodeLockTouchIDReason", comment: "Authentication required to proceed")
                case .faceID:
                    reason = localizedStringFor("PasscodeLockFaceIDReason", comment: "Authentication required to proceed")
                default:
                    reason = localizedStringFor("PasscodeLockBiometricAuthReason", comment: "Authentication required to proceed")
                }
            } else {
                reason = localizedStringFor("PasscodeLockBiometricAuthReason", comment: "Authentication required to proceed")
            }
        }

        context.localizedFallbackTitle = localizedStringFor("PasscodeLockBiometricAuthButton", comment: "Biometric authentication fallback button")
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
            success, error in
            
            self.handleBiometricAuthResult(success)
        }
    }
    
    fileprivate func handleBiometricAuthResult(_ success: Bool) {
        
        DispatchQueue.main.async {
            
            if success {
                EnterPasscodeState.incorrectPasscodeAttempts = 0
                self.delegate?.passcodeLockDidSucceed(self)
            }
        }
    }
    
    fileprivate func isBiometricAuthEnabled() -> Bool {
        
        let context = LAContext()
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}
