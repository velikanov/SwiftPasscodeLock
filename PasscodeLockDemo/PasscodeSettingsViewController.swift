//
//  PasscodeSettingsViewController.swift
//  PasscodeLockDemo
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit
import PasscodeLock

class PasscodeSettingsViewController: UIViewController {
    
    @IBOutlet weak var passcodeSwitch: UISwitch!
    @IBOutlet weak var changePasscodeButton: UIButton!
    @IBOutlet weak var testTextField: UITextField!
    @IBOutlet weak var testActivityButton: UIButton!
    @IBOutlet weak var authenticateNowButton: UIButton!
    
    fileprivate let configuration: PasscodeLockConfigurationType
    
    init(configuration: PasscodeLockConfigurationType) {
        
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        let repository = UserDefaultsPasscodeRepository()
        configuration = PasscodeLockConfiguration(repository: repository)
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - View
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePasscodeView()
    }
    
    func updatePasscodeView() {
        
        let hasPasscode = configuration.repository.hasPasscode
        
        changePasscodeButton.isHidden = !hasPasscode
        authenticateNowButton.isHidden = !hasPasscode
        passcodeSwitch.isOn = hasPasscode
    }
    
    // MARK: - Actions
    
    @IBAction func passcodeSwitchValueChange(_ sender: UISwitch) {
        
        let passcodeVC: PasscodeLockViewController
        
        if passcodeSwitch.isOn {
            
            passcodeVC = PasscodeLockViewController(state: .setPasscode, configuration: configuration)
            
        } else {
            
            passcodeVC = PasscodeLockViewController(state: .removePasscode, configuration: configuration)
            
            passcodeVC.successCallback = { lock in
                
                lock.repository.deletePasscode()
            }
        }
        
        present(passcodeVC, animated: true, completion: nil)
    }
    
    @IBAction func changePasscodeButtonTap(_ sender: UIButton) {
        
        let repo = UserDefaultsPasscodeRepository()
        let config = PasscodeLockConfiguration(repository: repo)
        
        let passcodeLock = PasscodeLockViewController(state: .changePasscode, configuration: config)
        
        present(passcodeLock, animated: true, completion: nil)
    }
    
    @IBAction func authenticateNowButtonTap(_ sender: UIButton) {
        
        let repo = UserDefaultsPasscodeRepository()
        let config = PasscodeLockConfiguration(repository: repo)
        
        let passcodeLock = PasscodeLockViewController(state: .enterOptionalPasscode, configuration: config, darkUI: sender.tag == 0 ? false : true)
        
        passcodeLock.successCallback = { lock in
            NSLog("Success")
        }

        passcodeLock.cancelCompletionCallback = { _ in
            NSLog("Cancelled")
        }
        
        passcodeLock.wrongPasswordCallback = { attemptNo in
            NSLog("Wrong password attempt no %d", attemptNo)
        }
        
        passcodeLock.tooManyAttemptsCallback = { attemptNo in
            NSLog("Maximum amount of %d attempts reached", attemptNo)
        }
        
        present(passcodeLock, animated: true, completion: nil)
        
    }
    
    @IBAction func testAlertButtonTap(_ sender: UIButton) {
        
        let alertVC = UIAlertController(title: "Test", message: "", preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alertVC, animated: true, completion: nil)
        
    }
    
    @IBAction func testActivityButtonTap(_ sender: UIButton) {
        
        let activityVC = UIActivityViewController(activityItems: ["Test"], applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = testActivityButton
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: 10, y: 20, width: 0, height: 0)
        
        present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func dismissKeyboard() {
        
        testTextField.resignFirstResponder()
    }
}
