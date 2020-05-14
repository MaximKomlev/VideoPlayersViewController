//
//  PlayerFullScreenViewInteractiveTransition.swift
//  ZoomController
//
//  Created by Maxim Komlev on 5/3/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

protocol PlayerFullScreenViewInteractiveTransitionDelegate: class {
    func isRotationNeeded() -> Bool
    func tryDismiss()
}

class PlayerFullScreenViewInteractiveTransition: UIPercentDrivenInteractiveTransition {

    // MARK: Fields
    
    private var playerFullScreenViewController: PlayerViewControllerTransitioningControllerProtocol!
    private let panGestureRecognizer = UIPanGestureRecognizer()

    // MARK: Initializer/Deinitializer

    init(playerFullScreenViewController: PlayerViewControllerTransitioningControllerProtocol) {
        super.init()
        
        self.playerFullScreenViewController = playerFullScreenViewController
        self.playerFullScreenViewController?.view.isUserInteractionEnabled = true

        self.panGestureRecognizer.addTarget(self, action: #selector(panHandler))
        self.playerFullScreenViewController?.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: Properties
    
    weak var interactiveTransitionDelegate: PlayerFullScreenViewInteractiveTransitionDelegate?
    
    var isRunning = false
    
    // MARK: Helpers
    
    private func validatePanEdge(point: CGPoint) -> Bool {
        let topSafeOffset = playerFullScreenViewController.view.safeAreaInsets.top
        let bottomSafeOffset = playerFullScreenViewController.view.safeAreaInsets.bottom + topSafeOffset
        if point.y > topSafeOffset && point.y < playerFullScreenViewController.view.frame.maxY - bottomSafeOffset {
            return true
        }
        return false
    }
    
    // MARK: Notification & events handlers

    @objc private func panHandler(sender: UIPanGestureRecognizer) {
        guard let view = sender.view else {
            return
        }

        var offset = sender.translation(in: view)
        if interactiveTransitionDelegate?.isRotationNeeded() ?? false {
            offset = offset.applying(CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2)))
        }
        let percent = offset.y / view.bounds.height
        
        switch sender.state {
        case .began:
            let beginPosition = sender.location(in: view)
            if validatePanEdge(point: beginPosition) {
                isRunning = true
                interactiveTransitionDelegate?.tryDismiss()
            }
        case .changed:
            update(percent)
        case .cancelled:
            isRunning = false
            cancel()
        case .ended:
            isRunning = false
            if percent > 0.5 {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}
