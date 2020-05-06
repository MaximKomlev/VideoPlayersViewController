//
//  BlurView.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/28/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

class BlurView: UIScrollView {
    
    // MARK: Fields
    
    
    // MARK: Initializer/Deinitializer
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {}
    
    // MARK: Properties
    
    var isBlurred: Bool = true {
        didSet {
            if (isBlurred) {
                self.backgroundColor = UIColor(white: 0, alpha: blurAlpha)
            } else {
                self.backgroundColor = UIColor.clear
            }
        }
    }
    
    var blurAlpha: CGFloat = 0.9
    
}

class BlurEffectView: UIView {
    
    // MARK: Fields

    lazy var blurEffectView: UIVisualEffectView = {
        return  UIVisualEffectView(effect: blurEffect)
    }()
    lazy var vibrancyEffectView: UIVisualEffectView = {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        return UIVisualEffectView(effect: vibrancyEffect)
    }()
    
    lazy var blurEffect: UIBlurEffect = {
        if #available(iOS 10, *) {
            return UIBlurEffect(style: .light)
        } else {
            return UIBlurEffect(style: .extraLight)
        }
    }()
    
    // MARK: Initializer/Deinitializer
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        self.clipsToBounds = true
        
        blurEffectView.alpha = 1
        blurEffectView.frame = frame
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        super.addSubview(blurEffectView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {}
    
    // MARK: Public methods
    
    override func addSubview(_ view: UIView) {
        blurEffectView.contentView.addSubview(view)
    }
    
    // MARK: Properties
    
    override var frame: CGRect {
        get {
            return super.frame
        } set (v) {
            super.frame = v
            blurEffectView.frame = super.bounds
            vibrancyEffectView.frame = super.bounds
        }
    }
    
}
