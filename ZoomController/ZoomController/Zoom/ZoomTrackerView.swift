//
//  ZoomTrackerView.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/24/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

struct ZoomTrackerViewConfig {
    static let witdth = CGFloat(48)
    static let cornerRadius = CGFloat(2)
    
    static let borderWidth = CGFloat(4)
    static let borderColor = UIColor.white.withAlphaComponent(0.4)

    static let backgroundColor = UIColor.black.withAlphaComponent(0.4)

    static let defaultTrackingAreaColor = UIColor.white.withAlphaComponent(0.4)
}

protocol ZoomTrackerViewProtocol: class {
    var trackingFrame: CGRect { get set }
    func reset()
}

class ZoomTrackerView: UIView, ZoomTrackerViewProtocol {
    
    // MARK: Fields
    
    private let shapeLayer = CAShapeLayer()
    private let trackingAreaLayer = CAShapeLayer()
    
    // MARK: Initializings/Deinitializing
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: ZoomTrackerViewConfig.cornerRadius).cgPath
        trackingAreaLayer.path = UIBezierPath(roundedRect: trackingFrame, cornerRadius: 1).cgPath
    }
    
    // MARK: ZoomTrackerViewProtocol
    
    var trackingFrame: CGRect = CGRect.zero {
        didSet {
            setNeedsLayout()
        }
    }

    var trackingColor: UIColor = ZoomTrackerViewConfig.defaultTrackingAreaColor {
        didSet {
            trackingAreaLayer.fillColor = trackingColor.cgColor
            setNeedsDisplay()
        }
    }

    func reset() {
        trackingFrame = bounds
        trackingAreaLayer.path = UIBezierPath(roundedRect: trackingFrame, cornerRadius: 1).cgPath
        setNeedsLayout()
    }

    // MARK: Helpers
    
    func initialize() {
        backgroundColor = UIColor.clear
                
        shapeLayer.fillColor = ZoomTrackerViewConfig.backgroundColor.cgColor
        shapeLayer.borderWidth = ZoomTrackerViewConfig.borderWidth
        shapeLayer.strokeColor = ZoomTrackerViewConfig.borderColor.cgColor
        layer.mask = shapeLayer
        layer.addSublayer(shapeLayer)
        
        trackingAreaLayer.fillColor = ZoomTrackerViewConfig.defaultTrackingAreaColor.cgColor
        layer.addSublayer(trackingAreaLayer)
    }
    
}
