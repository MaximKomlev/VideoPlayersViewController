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

        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        containerView.backgroundColor = fullScreenView.backgroundColor
        containerView.layer.cornerRadius = ThemeManager.shared.currentTheme.cornerRadius
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 0
        containerView.layer.masksToBounds = true

        let sourceRect = CGRect(origin: containerView.center, size: containerView.bounds.size)
        let destinationRect = viewController.view.convert(transitioningCoordinator.initialViewRect(),
                                                          from: transitioningCoordinator.initialView())

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic, .layoutSubviews], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1) {
                containerView.bounds.size = destinationRect.size
                containerView.center = destinationRect.origin
                containerView.layoutIfNeeded()
            }
        }) { (_) in
            containerView.layer.cornerRadius = 0
            if !transitionContext.transitionWasCancelled {
                fullScreenView.removeFromSuperview()
            } else {
                // potentially UITransitionView bug,
                // safe area is not reseting when animation was canceled,
                // so to force relayout whole stack of views, needs to resize a bit containerView
                let ratio = sourceRect.size.width / sourceRect.size.height
                let sizeAdjustment = CGFloat(50)
                containerView.bounds.size = CGSize(width: sourceRect.size.width - sizeAdjustment * ratio,
                                                   height: sourceRect.size.height - sizeAdjustment)
                //
                containerView.bounds.size = sourceRect.size
                containerView.center = sourceRect.origin
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.transitioningCoordinator.transitionFinished(controllerTransitioning: self,
                                                                      wasCancelled: transitionContext.transitionWasCancelled)
        }
    }
}

