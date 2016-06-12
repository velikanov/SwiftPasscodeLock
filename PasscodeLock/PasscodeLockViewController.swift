//
//  PasscodeLockViewController.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

public class PasscodeLockViewController: UIViewController, PasscodeLockTypeDelegate {
    
    public enum LockState {
        case EnterPasscode
        case SetPasscode
        case ChangePasscode
        case RemovePasscode
        
        func getState() -> PasscodeLockStateType {
            
            switch self {
            case .EnterPasscode: return EnterPasscodeState()
            case .SetPasscode: return SetPasscodeState()
            case .ChangePasscode: return ChangePasscodeState()
            case .RemovePasscode: return EnterPasscodeState(allowCancellation: true)
            }
        }
    }
    
    @IBOutlet public weak var titleLabel: UILabel?
    @IBOutlet public weak var descriptionLabel: UILabel?
    @IBOutlet public var placeholders: [PasscodeSignPlaceholderView] = [PasscodeSignPlaceholderView]()
    @IBOutlet public weak var cancelButton: UIButton?
    @IBOutlet public weak var deleteSignButton: UIButton?
    @IBOutlet public weak var touchIDButton: UIButton?
    @IBOutlet public weak var placeholdersX: NSLayoutConstraint?
    
    public var successCallback: ((lock: PasscodeLockType) -> Void)?
    public var dismissCompletionCallback: (()->Void)?
    public var animateOnDismiss: Bool
    public var notificationCenter: NSNotificationCenter?
    
    internal let passcodeConfiguration: PasscodeLockConfigurationType
    internal let passcodeLock: PasscodeLockType
    internal var isPlaceholdersAnimationCompleted = true
    
    private var shouldTryToAuthenticateWithBiometrics = true
    
    // MARK: - Initializers
    
	public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true, nibName: String = "PasscodeLockView", bundle: NSBundle? = nil) {
        
        self.animateOnDismiss = animateOnDismiss
        
        passcodeConfiguration = configuration
        passcodeLock = PasscodeLock(state: state, configuration: configuration)
        
        let bundleToUse = bundle ?? bundleForResource(nibName, ofType: "nib")
        
        super.init(nibName: nibName, bundle: bundleToUse)
        
        passcodeLock.delegate = self
        notificationCenter = NSNotificationCenter.defaultCenter()
    }
    
    public convenience init(state: LockState, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true) {
        
        self.init(state: state.getState(), configuration: configuration, animateOnDismiss: animateOnDismiss)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        clearEvents()
    }
    
    // MARK: - View
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton?.setTitle(localizedStringFor("PasscodeLockCancelButtonTitle", comment: "Cancel Button Title"), forState: .Normal)
        deleteSignButton?.setTitle(localizedStringFor("PasscodeLockDeleteButtonTitle", comment: "Delete Button Title"), forState: .Normal)
        deleteSignButton?.enabled = false
        
        setupEvents()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePasscodeView()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldTryToAuthenticateWithBiometrics && passcodeConfiguration.shouldRequestTouchIDImmediately {
        
            authenticateWithBiometrics()
        }
    }
    
    internal func updatePasscodeView() {
        
        titleLabel?.text = passcodeLock.state.title
        descriptionLabel?.text = passcodeLock.state.description
        cancelButton?.hidden = !passcodeLock.state.isCancellableAction
        touchIDButton?.hidden = !passcodeLock.isTouchIDAllowed
    }
    
    // MARK: - Events
    
    private func setupEvents() {
        
        notificationCenter?.addObserver(self, selector: #selector(PasscodeLockViewController.appWillEnterForegroundHandler(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)
        notificationCenter?.addObserver(self, selector: #selector(PasscodeLockViewController.appDidEnterBackgroundHandler(_:)), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    private func clearEvents() {
        
        notificationCenter?.removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        notificationCenter?.removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    public func appWillEnterForegroundHandler(notification: NSNotification) {
        
        if passcodeConfiguration.shouldRequestTouchIDImmediately {
            authenticateWithBiometrics()
        }
    }
    
    public func appDidEnterBackgroundHandler(notification: NSNotification) {
        
        shouldTryToAuthenticateWithBiometrics = false
    }
    
    // MARK: - Actions
    
    @IBAction func passcodeSignButtonTap(sender: PasscodeSignButton) {
        
        guard isPlaceholdersAnimationCompleted else { return }
        
        passcodeLock.addSign(sender.passcodeSign)
    }
    
    @IBAction func cancelButtonTap(sender: UIButton) {
        
        dismissPasscodeLock(passcodeLock)
    }
    
    @IBAction func deleteSignButtonTap(sender: UIButton) {
        
        passcodeLock.removeSign()
    }
    
    @IBAction func touchIDButtonTap(sender: UIButton) {
        
        passcodeLock.authenticateWithBiometrics()
    }
    
    public func authenticateWithBiometrics() {
        
        guard passcodeConfiguration.repository.hasPasscode else { return }

        if passcodeLock.isTouchIDAllowed {
            
            passcodeLock.authenticateWithBiometrics()
        }
    }
    
    internal func dismissPasscodeLock(lock: PasscodeLockType, completionHandler: (() -> Void)? = nil) {
        
        // if presented as modal
        if presentingViewController?.presentedViewController == self {
            
            dismissViewControllerAnimated(animateOnDismiss, completion: { [weak self] _ in
                
                self?.dismissCompletionCallback?()
                
                completionHandler?()
            })
            
            return
            
        // if pushed in a navigation controller
        } else if navigationController != nil {
        
            navigationController?.popViewControllerAnimated(animateOnDismiss)
        }
        
        dismissCompletionCallback?()
        
        completionHandler?()
    }
    
    // MARK: - Animations
    
    internal func animateWrongPassword() {
        
        deleteSignButton?.enabled = false
        isPlaceholdersAnimationCompleted = false
        
        animatePlaceholders(placeholders, toState: .Error)
        
        placeholdersX?.constant = -40
        view.layoutIfNeeded()
        
        UIView.animateWithDuration(
            0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                
                self.placeholdersX?.constant = 0
                self.view.layoutIfNeeded()
            },
            completion: { completed in
                
                self.isPlaceholdersAnimationCompleted = true
                self.animatePlaceholders(self.placeholders, toState: .Inactive)
        })
    }
    
    internal func animatePlaceholders(placeholders: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {
        
        for placeholder in placeholders {
            
            placeholder.animateState(state)
        }
    }
    
    private func animatePlacehodlerAtIndex(index: Int, toState state: PasscodeSignPlaceholderView.State) {
        
        guard index < placeholders.count && index >= 0 else { return }
        
        placeholders[index].animateState(state)
    }

    // MARK: - PasscodeLockDelegate
    
    public func passcodeLockDidSucceed(lock: PasscodeLockType) {
        
        deleteSignButton?.enabled = true
        animatePlaceholders(placeholders, toState: .Inactive)
        dismissPasscodeLock(lock, completionHandler: { [weak self] _ in
            self?.successCallback?(lock: lock)
        })
    }
    
    public func passcodeLockDidFail(lock: PasscodeLockType) {
        
        animateWrongPassword()
    }
    
    public func passcodeLockDidChangeState(lock: PasscodeLockType) {
        
        updatePasscodeView()
        animatePlaceholders(placeholders, toState: .Inactive)
        deleteSignButton?.enabled = false
    }
    
    public func passcodeLock(lock: PasscodeLockType, addedSignAtIndex index: Int) {
        
        animatePlacehodlerAtIndex(index, toState: .Active)
        deleteSignButton?.enabled = true
    }
    
    public func passcodeLock(lock: PasscodeLockType, removedSignAtIndex index: Int) {
        
        animatePlacehodlerAtIndex(index, toState: .Inactive)
        
        if index == 0 {
            
            deleteSignButton?.enabled = false
        }
    }
}
