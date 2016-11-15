//
//  LockSplashView.swift
//  PasscodeLock
//
//  Created by Chris Ziogas on 19/12/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

open class LockSplashView: UIView {
    
    fileprivate lazy var logo: UIImageView = {
        
        let image = UIImage(named: "fake-logo")
        let view = UIImageView(image: image)
        view.contentMode = UIViewContentMode.center
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    ///////////////////////////////////////////////////////
    // MARK: - Initializers
    ///////////////////////////////////////////////////////
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        addSubview(logo)
        setupLayout()
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///////////////////////////////////////////////////////
    // MARK: - Layout
    ///////////////////////////////////////////////////////
    
    fileprivate func setupLayout() {
        
        let views = ["logo": logo]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[logo]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[logo]", options: [], metrics: nil, views: views))
        
        addConstraint(NSLayoutConstraint(item: logo, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: logo, attribute: .centerY, multiplier: 1, constant: 0))
    }
}
