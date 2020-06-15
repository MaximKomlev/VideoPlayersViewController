//
//  PlayerWidgetViewControllerTransitioning.swift
//  ZoomController
//
//  Created by Maxim Komlev on 5/1/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

class PlayerWidgetViewControllerTransitioning: BaseViewControllerTransitioning, UIViewControllerAnimatedTransitioning {
        
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return ThemeManager.shared.currentTheme.animationDuration04
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fullScreenViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let viewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fullScreenView = fullScreenViewController.view else {
                return
        }

        transitioningCoordinator.transitionStarted(controllerTransitioning: self)

        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        containerView.backgroundColor = fullScreenView.backgroundColor
        containerView.layer.cornerRadius = ThemeManager.shared.currentTheme.cornerRadius
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 0
        containerView.layer.masksToBounds = true

        let sourceRect = CGRect(origin: containerView.center, size: containerView.bounds.size)
        var destinationRect = transitioningCoordinator.initialViewRect(at: viewController)
        let isRotationNeeded = transitioningCoordinator.isRotationNeeded()
        if isRotationNeeded {
            var playerCenter = destinationRect.origin
            let interfaceOrientation = containerView.window?.windowScene?.interfaceOrientation ?? .landscapeRight
            playerCenter = playerCenter.applying(CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2 )))
            if interfaceOrientation == .landscapeRight {
                playerCenter.x = -playerCenter.x
            } else {
                playerCenter.x = viewController.view.bounds.width + playerCenter.x
            }
            destinationRect = CGRect(origin: playerCenter, size: destinationRect.size)
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: [.layoutSubviews], animations: {
            containerView.bounds.size = destinationRect.size
            containerView.center = destinationRect.origin
            if isRotationNeeded {
                let angel = containerView.window?.windowScene?.interfaceOrientation ?? .landscapeRight ==  .landscapeRight ?
                    -CGFloat(Double.pi / 2) :
                    CGFloat(Double.pi / 2)
                containerView.transform = CGAffineTransform(rotationAngle: angel)
            }
        }) { (_) in
            containerView.layer.cornerRadius = 0
            if !transitionContext.transitionWasCancelled {
                fullScreenView.removeFromSuperview()
                self.completeTransition(for: transitionContext)
            } else {
                containerView.center = sourceRect.origin
                containerView.bounds.size = sourceRect.size
                self.completeTransition(for: transitionContext)
            }
        }
    }
    
}

