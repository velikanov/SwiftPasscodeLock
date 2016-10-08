//
//  PasscodeLockPresenter.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

public class PasscodeLockPresenter {
    
    private var mainWindow: UIWindow?
    private var passcodeWindowLevel: UIWindowLevel
    
    private lazy var passcodeLockWindow: UIWindow = {
        
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window.windowLevel = 0
        window.makeKeyAndVisible()
        
        return window
    }()
    
    private let passcodeConfiguration: PasscodeLockConfigurationType
    public var isPasscodePresented = false
    
    public let passcodeLockVC: PasscodeLockViewController
    
    public init(mainWindow window: UIWindow?, passcodeWindowLevel: UIWindowLevel = 2,
                           configuration: PasscodeLockConfigurationType, viewController: PasscodeLockViewController)
    {
        mainWindow = window
        mainWindow?.windowLevel = 1
        passcodeConfiguration = configuration
        self.passcodeWindowLevel = passcodeWindowLevel
        
        passcodeLockVC = viewController
    }

    public convenience init(mainWindow window: UIWindow?, passcodeWindowLevel: UIWindowLevel = 2,
                                       configuration: PasscodeLockConfigurationType)
    {
        let passcodeLockVC = PasscodeLockViewController(state: .EnterPasscode, configuration: configuration)
        
        self.init(mainWindow: window, passcodeWindowLevel: passcodeWindowLevel,
                  configuration: configuration, viewController: passcodeLockVC)
    }
    
    // HACK: below function that handles not presenting the keyboard in case Passcode is presented
    //       is a smell in the code that had to be introduced for iOS9 where Apple decided to move the keyboard
    //       in a UIRemoteKeyboardWindow.
    //       This doesn't allow our Passcode Lock window to move on top of keyboard.
    //       Setting a higher windowLevel to our window or even trying to change keyboards'
    //       windowLevel has been tried without luck.
    //
    //       Revise in a later version and remove the hack if not needed
    func toggleKeyboardVisibility(hide hide: Bool) {
        if let keyboardWindow = UIApplication.sharedApplication().windows.last
            where keyboardWindow.description.hasPrefix("<UIRemoteKeyboardWindow")
        {
            keyboardWindow.alpha = hide ? 0.0 : 1.0
        }
    }
    
    public func presentPasscodeLock() {
        
        guard passcodeConfiguration.repository.hasPasscode else { return }
        guard !isPasscodePresented else { return }
        
        isPasscodePresented = true
        passcodeLockWindow.windowLevel = passcodeWindowLevel
        
        toggleKeyboardVisibility(hide: true)
        
        let userDismissCompletionCallback = passcodeLockVC.dismissCompletionCallback
        
        passcodeLockVC.dismissCompletionCallback = { [weak self] in
            
            userDismissCompletionCallback?()
            
            self?.dismissPasscodeLock()
        }
        
        passcodeLockWindow.rootViewController = passcodeLockVC
    }
    
    public func dismissPasscodeLock(animated animated: Bool = true) {
        
        isPasscodePresented = false
        mainWindow?.windowLevel = 1
        mainWindow?.makeKeyAndVisible()
        
        if animated {
            UIView.animateWithDuration(
                0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: [.CurveEaseInOut],
                animations: { [weak self] in
                    
                    self?.passcodeLockWindow.alpha = 0
                },
                completion: { [weak self] _ in
                    
                    self?.passcodeLockWindow.windowLevel = 0
                    self?.passcodeLockWindow.rootViewController = nil
                    self?.passcodeLockWindow.alpha = 1
                    self?.toggleKeyboardVisibility(hide: false)
                }
            )
        } else {
            passcodeLockWindow.windowLevel = 0
            passcodeLockWindow.rootViewController = nil
            toggleKeyboardVisibility(hide: false)
        }
    }
}
