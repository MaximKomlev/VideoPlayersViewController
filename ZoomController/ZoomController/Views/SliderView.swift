//
//  SliderView.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/28/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

class Slider: UISlider {
    
    // MARK: Fields
    
    private let delegates = Eventer()
    
    // MARK Initializers/Deinitializer

    deinit {
        delegates.removeAll()
    }

    // MARK: View life cycle

    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        delegates.invoke(source: self, eventArgs: EventArgs())
        return super.continueTracking(touch, with: event)
    }
    
    // MARK: Properties
    
    var trackBounds: CGRect {
        return trackRect(forBounds: bounds)
    }
    
    var trackFrame: CGRect {
        guard let superView = superview else { return CGRect.zero }
        return self.convert(trackBounds, to: superView)
    }
    
    var thumbBounds: CGRect {
        return thumbRect(forBounds: frame, trackRect: trackBounds, value: value)
    }
    
    var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackFrame, value: value)
    }
    
    // MARK: Public methods
    
    public func addTarget(_ target: NSObject, action: Selector) {
        delegates.add(target: target, action: action)
    }
    
    public func removeTarget(_ target: NSObject? = nil, action: Selector?) {
        if (target == nil) {
            delegates.removeAll()
        } else {
            if (action != nil) {
                delegates.remove(target: target!, action: action!)
            } else {
                delegates.remove(target: target!)
            }
        }
    }
    
}

class SliderView : UIView {
    
    // MARK: Fields
    
    var granularity: CGFloat = 1
    
    private let slider = Slider()
    private let fLabel = UILabel()
    private let rLabel = UILabel()
    
    // MARK: Initializer/Deinitializer
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public convenience init(size: CGSize) {
        self.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeUI()
    }
    
    public convenience init(frame: CGRect, frontLabelText: String, rearLabelText: String) {
        self.init(frame: frame)
        
        fLabel.text = frontLabelText
        rLabel.text = rearLabelText
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
    }
    
    // MARK: View life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let marging = ThemeManager.shared.currentTheme.contentMargin
        let minSliderWidth: CGFloat = 100
        
        let szFLabel = fLabel.attributedText != nil ? sizeOfAttributedStringForLabel(fLabel) : CGSize.zero
        let szRLabel = rLabel.attributedText != nil ? sizeOfAttributedStringForLabel(rLabel) : CGSize.zero
        
        var fLabelWidth = szFLabel.width
        var rLabelWidth = szRLabel.width
        
        let frameWidth = bounds.width
        let frameHeight = bounds.height
        
        if (fLabelWidth + rLabelWidth + 3 * marging + minSliderWidth > frameWidth) {
            let diff = frameWidth - (3 * marging + minSliderWidth)
            if (fLabelWidth > 0) {
                if (rLabelWidth > 0) {
                    fLabelWidth = diff / 2
                } else {
                    fLabelWidth = diff
                }
            }
            
            if (rLabelWidth > 0) {
                if (fLabelWidth > 0) {
                    rLabelWidth = diff / 2
                } else {
                    rLabelWidth = diff
                }
            }
        }
        
        var xFLabel: CGFloat = 0
        if (fLabelWidth > 0) {
            xFLabel += marging
        }
        let yFLable = (frameHeight - szFLabel.height) / 2
        let xSlider = xFLabel + fLabelWidth + (fLabelWidth > 0 ? marging / 2 : 0)
        let sliderWidth = frameWidth - (2 * marging + fLabelWidth + rLabelWidth) - (rLabelWidth > 0 ? marging : 0)
        let ySlider = (frameHeight - slider.bounds.height) / 2
        let xRLabel = xFLabel + fLabelWidth + marging + sliderWidth
        let yRLable = (frameHeight - szRLabel.height) / 2
        
        fLabel.frame = CGRect(x: xFLabel, y: yFLable, width: fLabelWidth, height: szFLabel.height)
        rLabel.frame = CGRect(x: xRLabel, y: yRLable, width: rLabelWidth, height: szRLabel.height)
        slider.frame = CGRect(x: xSlider, y: ySlider, width: sliderWidth, height: slider.bounds.height)
    }
    
    // MARK: Public methods
    
    public func addSliderEventHandler(_ target: Any?, action: Selector) {
        self.slider.addTarget(target, action: action, for: .valueChanged)
    }

    public func removeSliderEventHandler() {
        self.slider.removeTarget(self, action: nil, for: .valueChanged)
    }

    public func addSliderStartEventHandler(_ target: Any?, action: Selector) {
        self.slider.addTarget(target, action: action, for: .touchDown)
    }
    
    public func removeSliderStartEventHandler() {
        self.slider.removeTarget(self, action: nil, for: .touchDown)
    }

    public func addSliderEndEventHandler(_ target: Any?, action: Selector) {
        self.slider.addTarget(target, action: action, for: .touchUpInside)
        self.slider.addTarget(target, action: action, for: .touchUpOutside)
    }
    
    public func removeSliderEndEventHandler() {
        self.slider.removeTarget(self, action: nil, for: .touchUpInside)
        self.slider.removeTarget(self, action: nil, for: .touchUpOutside)
    }

    public func removeEventsHandlers() {
        self.slider.removeTarget(self, action: nil, for: .touchUpInside)
        self.slider.removeTarget(self, action: nil, for: .touchUpOutside)
        self.slider.removeTarget(self, action: nil, for: .touchDown)
        self.slider.removeTarget(self, action: nil, for: .valueChanged)
    }

    public func addSliderTrackingEventHandler(_ target: NSObject, action: Selector) {
        self.slider.addTarget(target, action: action)
    }

    // MARK: Properies
    
    var thumbRect: CGRect {
        get {
            return slider.thumbFrame
        }
    }

    var value: CGFloat {
        get {
            return CGFloat(slider.value)
        } set (v) {
            if (slider.value != Float(v)) {
                self.slider.value = Float(v)
                self.setNeedsLayout()
            }
        }
    }

    var maxValue: CGFloat {
        get {
            return CGFloat(slider.maximumValue)
        } set (v) {
            if (slider.maximumValue != Float(v)) {
                self.slider.maximumValue = Float(v)
                self.setNeedsLayout()
            }
        }
    }

    var minValue: CGFloat {
        get {
            return CGFloat(slider.minimumValue)
        } set (v) {
            if (slider.minimumValue != Float(v)) {
                self.slider.minimumValue = Float(v)
                self.setNeedsLayout()
            }
        }
    }

    var frontText: String? {
        get {
            return self.fLabel.text
        }
        set (v) {
            if (self.fLabel.text != v) {
                self.fLabel.text = v
                self.setNeedsLayout()
            }
        }
    }
    
    var frontAttributedText: NSAttributedString? {
        get {
            return self.fLabel.attributedText
        }
        set (v) {
            if (v != nil && !(self.fLabel.attributedText?.isEqual(to: v!))!) {
                self.fLabel.attributedText = v
                self.setNeedsLayout()
            }
        }
    }

    var rearText: String? {
        get {
            return self.rLabel.text
        }
        set (v) {
            if (self.rLabel.text != v) {
                self.rLabel.text = v
                self.setNeedsLayout()
            }
        }
    }
    
    var rearAttributedText: NSAttributedString? {
        get {
            return self.rLabel.attributedText
        }
        set (v) {
            if (v != nil && !(self.rLabel.attributedText?.isEqual(to: v!))!) {
                self.rLabel.attributedText = v
                self.setNeedsLayout()
            }
        }
    }
    
    var frontRearTextCollor: UIColor! {
        didSet {
            self.rLabel.textColor = frontRearTextCollor
            self.fLabel.textColor = frontRearTextCollor
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            slider.isEnabled = isEnabled
            fLabel.isEnabled = isEnabled
            rLabel.isEnabled = isEnabled
        }
    }

    // MARK: Helpers
    
    func initializeUI() {
        clipsToBounds = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        slider.isContinuous = false
        slider.value = 0
        slider.isUserInteractionEnabled = true
        slider.backgroundColor = UIColor.clear
        slider.sizeToFit()
        addSubview(slider)

        rLabel.textColor = ThemeManager.shared.currentTheme.sysLabelLightColor
        rLabel.font = UIFont.systemFont(ofSize: ThemeManager.shared.currentTheme.fontSizeLabel16)
        rLabel.lineBreakMode = .byTruncatingTail
        rLabel.numberOfLines = 1
        rLabel.textAlignment = .left
        addSubview(rLabel)

        fLabel.textColor = ThemeManager.shared.currentTheme.sysLabelLightColor
        fLabel.font = UIFont.systemFont(ofSize: ThemeManager.shared.currentTheme.fontSizeLabel16)
        fLabel.lineBreakMode = .byTruncatingTail
        fLabel.numberOfLines = 1
        fLabel.textAlignment = .left
        addSubview(fLabel)
        
        bounds.size.height = slider.bounds.height
    }
        
}
