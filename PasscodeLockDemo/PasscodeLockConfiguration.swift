//
//  PasscodeLockConfiguration.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import PasscodeLock

struct PasscodeLockConfiguration: PasscodeLockConfigurationType {
    
    let repository: PasscodeRepositoryType
    var isBiometricAuthAllowed: Bool = true
    let shouldRequestBiometricAuthImmediately: Bool = true
    var biometricAuthReason: String? = nil

    init(repository: PasscodeRepositoryType) {
        
        self.repository = repository
    }
    
    init() {
        
        self.repository = UserDefaultsPasscodeRepository()
    }
}
