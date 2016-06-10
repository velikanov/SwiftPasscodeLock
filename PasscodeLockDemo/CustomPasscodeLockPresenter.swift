//
//  CustomPasscodeLockPresenter.swift
//  PasscodeLock
//
//  Adds:
//  * Splash view
//  * Handling of IncorrectPasscodeAttempts
//
//  Created by Chris Ziogas on 19/12/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import PasscodeLock

// this constant is set here so as it can be used from CustomPasscodeLockViewController
// it is not the best practice, but it set like this for demo purposes
let UserDefaultsIncorrectPasscodeAttemptsReachedName = "passcode.incorrectPasscodeAttemptsReached"

class CustomPasscodeLockPresenter: PasscodeLockPresenter {
    
    private let notificationCenter: NSNotificationCenter
    
    private let splashView: UIView
    
    init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType) {
        
        notificationCenter = NSNotificationCenter.defaultCenter()
        
        splashView = LockSplashView()
        
        // TIP: you can set your custom viewController that has added functionality in a custom .xib too
        let passcodeLockVC = CustomPasscodeLockViewController(state: .EnterPasscode, configuration: configuration)
        
        super.init(mainWindow: window, configuration: configuration, viewController: passcodeLockVC)
        
        // add notifications observers
        notificationCenter.addObserver(
            self,
            selector: #selector(self.applicationDidLaunched),
            name: UIApplicationDidFinishLaunchingNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(self.applicationDidEnterBackground),
            name: UIApplicationDidEnterBackgroundNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(self.applicationWillEnterForeground),
            name: UIApplicationWillEnterForegroundNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(self.incorrectPasscodeAttemptsReached),
            name: PasscodeLockIncorrectPasscodeNotification,
            object: nil
        )
    }
    
    deinit {
        // remove all notfication observers
        notificationCenter.removeObserver(self)
    }
    
    dynamic func applicationDidLaunched() -> Void {
        
        // show the Pin Lock presenter
        presentPasscodeLock()
    }
    
    dynamic func applicationDidEnterBackground() -> Void {
        
        // present PIN lock
        presentPasscodeLock()
        
        // add splashView for iOS app background swithcer
        addSplashView()
    }
    
    dynamic func applicationWillEnterForeground() -> Void {
        
        // remove splashView for iOS app background swithcer
        removeSplashView()

        // TODO: handle how user will continue
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsIncorrectPasscodeAttemptsReachedName),
            let customPasscodeLockVC = passcodeLockVC as? CustomPasscodeLockViewController
        {
            customPasscodeLockVC.showLockedAlert()
        }
    }
    
    dynamic func incorrectPasscodeAttemptsReached() -> Void {
        
        // store that incorrect passcode attempts has reached
        // so as app knows even if app is being force-quited
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaultsIncorrectPasscodeAttemptsReachedName)
        
        if let customPasscodeLockVC = passcodeLockVC as? CustomPasscodeLockViewController {
            customPasscodeLockVC.showLockedAlert()
        }
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