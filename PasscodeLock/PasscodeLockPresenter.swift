//
//  PasscodeLockPresenter.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

open class PasscodeLockPresenter {
    
    fileprivate var mainWindow: UIWindow?
    
    fileprivate lazy var passcodeLockWindow: UIWindow = {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        window.windowLevel = 0
        window.makeKeyAndVisible()
        
        return window
    }()
    
    fileprivate let passcodeConfiguration: PasscodeLockConfigurationType
    open var isPasscodePresented = false
    
    open let passcodeLockVC: PasscodeLockViewController
    
    public init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType, viewController: PasscodeLockViewController) {
        
        mainWindow = window
        mainWindow?.windowLevel = 1
        passcodeConfiguration = configuration
        
        passcodeLockVC = viewController
    }

    public convenience init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType) {
        let passcodeLockVC = PasscodeLockViewController(state: .enterPasscode, configuration: configuration)
        
        self.init(mainWindow: window, configuration: configuration, viewController: passcodeLockVC)
    }
    
    // HACK: below function that handles not presenting the keyboard in case Passcode is presented
    //       is a smell in the code that had to be introduced for iOS9 where Apple decided to move the keyboard
    //       in a UIRemoteKeyboardWindow.
    //       This doesn't allow our Passcode Lock window to move on top of keyboard.
    //       Setting a higher windowLevel to our window or even trying to change keyboards'
    //       windowLevel has been tried without luck.
    //
    //       Revise in a later version and remove the hack if not needed
    func toggleKeyboardVisibility(hide: Bool) {
        if let keyboardWindow = UIApplication.shared.windows.last,
            keyboardWindow.description.hasPrefix("<UIRemoteKeyboardWindow")
        {
            keyboardWindow.alpha = hide ? 0.0 : 1.0
        }
    }
    
    open func presentPasscodeLock() {
        
        guard passcodeConfiguration.repository.hasPasscode else { return }
        guard !isPasscodePresented else { return }
        
        isPasscodePresented = true
        passcodeLockWindow.windowLevel = 2
        
        toggleKeyboardVisibility(hide: true)
        
        let userDismissCompletionCallback = passcodeLockVC.dismissCompletionCallback
        
        passcodeLockVC.dismissCompletionCallback = { [weak self] in
            
            userDismissCompletionCallback?()
            
            self?.dismissPasscodeLock()
        }
        
        passcodeLockWindow.rootViewController = passcodeLockVC
    }
    
    open func dismissPasscodeLock(animated: Bool = true) {
        
        isPasscodePresented = false
        mainWindow?.windowLevel = 1
        mainWindow?.makeKeyAndVisible()
        
        if animated {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: [.curveEaseInOut],
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
