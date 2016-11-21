//
//  CustomPasscodeLockPresenter.swift
//  PasscodeLock
//
//  Created by Chris Ziogas on 19/12/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import PasscodeLock

class CustomPasscodeLockPresenter: PasscodeLockPresenter {
    
    private let notificationCenter: NSNotificationCenter
    
    private let splashView: UIView
    
    var isFreshAppLaunch = true
    
    init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType) {
        
        notificationCenter = NSNotificationCenter.defaultCenter()
        
        splashView = LockSplashView()
        
        // TIP: you can set your custom viewController that has added functionality in a custom .xib too
        let passcodeLockVC = PasscodeLockViewController(state: .EnterPasscode, configuration: configuration)
        
        super.init(mainWindow: window, configuration: configuration, viewController: passcodeLockVC)
        
        // add notifications observers
        notificationCenter.addObserver(
            self,
            selector: #selector(CustomPasscodeLockPresenter.applicationDidLaunched),
            name: UIApplicationDidFinishLaunchingNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(CustomPasscodeLockPresenter.applicationDidEnterBackground),
            name: UIApplicationDidEnterBackgroundNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(CustomPasscodeLockPresenter.applicationDidBecomeActive),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        // remove all notfication observers
        notificationCenter.removeObserver(self)
    }
    
    dynamic func applicationDidLaunched() -> Void {
        
        // start the Pin Lock presenter
        passcodeLockVC.successCallback = { [weak self] _ in
            
            // we can set isFreshAppLaunch to false
            self?.isFreshAppLaunch = false
        }
        
        presentPasscodeLock()
    }
    
    dynamic func applicationDidEnterBackground() -> Void {
        
        // present PIN lock
        presentPasscodeLock()
        
        // add splashView for iOS app background swithcer
        addSplashView()
    }
    
    dynamic func applicationDidBecomeActive() -> Void {
        
        // remove splashView for iOS app background swithcer
        removeSplashView()
    }
    
    private func addSplashView() {
        
        // add splashView for iOS app background swithcer
        if isPasscodePresented {
            passcodeLockVC.view.addSubview(splashView)
        } else {
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                appDelegate.window?.addSubview(splashView)
            }
        }
    }
    
    private func removeSplashView() {
        
        // remove splashView for iOS app background swithcer
        splashView.removeFromSuperview()
    }
}
