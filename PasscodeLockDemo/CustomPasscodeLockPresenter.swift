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
    
    fileprivate let notificationCenter: NotificationCenter
    
    fileprivate let splashView: UIView
    
    var isFreshAppLaunch = true
    
    init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType) {
        
        notificationCenter = NotificationCenter.default
        
        splashView = LockSplashView()
        
        // TIP: you can set your custom viewController that has added functionality in a custom .xib too
        let passcodeLockVC = PasscodeLockViewController(state: .enterPasscode, configuration: configuration)
        
        super.init(mainWindow: window, configuration: configuration, viewController: passcodeLockVC)
        
        // add notifications observers
        notificationCenter.addObserver(
            self,
            selector: #selector(CustomPasscodeLockPresenter.applicationDidLaunched),
            name: NSNotification.Name.UIApplicationDidFinishLaunching,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(CustomPasscodeLockPresenter.applicationDidEnterBackground),
            name: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(CustomPasscodeLockPresenter.applicationDidBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
    }
    
    deinit {
        // remove all notfication observers
        notificationCenter.removeObserver(self)
    }
    
    @objc dynamic func applicationDidLaunched() -> Void {
        
        // start the Pin Lock presenter
        passcodeLockVC.successCallback = { [weak self] _ in
            
            // we can set isFreshAppLaunch to false
            self?.isFreshAppLaunch = false
        }
        
        presentPasscodeLock()
    }
    
    @objc dynamic func applicationDidEnterBackground() -> Void {
        
        // present PIN lock
        presentPasscodeLock()
        
        // add splashView for iOS app background swithcer
        addSplashView()
    }
    
    @objc dynamic func applicationDidBecomeActive() -> Void {
        
        // remove splashView for iOS app background swithcer
        removeSplashView()
    }
    
    fileprivate func addSplashView() {
        
        // add splashView for iOS app background swithcer
        if isPasscodePresented {
            passcodeLockVC.view.addSubview(splashView)
        } else {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.window?.addSubview(splashView)
            }
        }
    }
    
    fileprivate func removeSplashView() {
        
        // remove splashView for iOS app background swithcer
        splashView.removeFromSuperview()
    }
}
