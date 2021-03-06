//
//  PlayerFullScreenViewControllerTransitioning.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/30/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

class BaseViewControllerTransitioning: NSObject {
    
    // MARK: Fields
    
    let transitioningCoordinator: PlayerViewControllerTransitioningCoordinatorProtocol!

    // MARK: Initializers/Deinitializer
    
    required init(coordinator: PlayerViewControllerTransitioningCoordinatorProtocol) {
        transitioningCoordinator = coordinator

        super.init()
    }
    
    deinit {}
    
    // MARK: Properties
    
    var isFullScreenDirection: Bool {
        return false
    }
    
    // MARK: Helpers
    
    func completeTransition(for transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        transitioningCoordinator.transitionFinished(controllerTransitioning: self,
                                                                  wasCancelled: transitionContext.transitionWasCancelled)
    }

}

class PlayerFullScreenViewControllerTransitioning: BaseViewControllerTransitioning, UIViewControllerAnimatedTransitioning {
    
    override var isFullScreenDirection: Bool {
        return true
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return ThemeManager.shared.currentTheme.animationDuration04
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let viewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fullScreenViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fullScreenView = fullScreenViewController.view else {
                return
        }

        transitioningCoordinator.transitionStarted(controllerTransitioning: self)

        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        containerView.backgroundColor = fullScreenView.backgroundColor
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = ThemeManager.shared.currentTheme.cornerRadius
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 0
        containerView.layer.masksToBounds = true

        containerView.addSubview(fullScreenView)
        fullScreenView.bounds = containerView.bounds
        fullScreenView.center = containerView.center
        
        let initialRect = transitioningCoordinator.initialViewRect(at: viewController)
        containerView.center = initialRect.origin
        containerView.bounds.size = initialRect.size

        UIView.animate(withDuration: duration, delay: 0, options: [.layoutSubviews], animations: {
            containerView.bounds = fullScreenView.window?.bounds ?? UIScreen.main.bounds
            containerView.center = fullScreenView.window?.center ?? CGPoint(x: UIScreen.main.bounds.width / 2,
                                                                            y: UIScreen.main.bounds.height / 2)
            fullScreenView.bounds = containerView.bounds
            fullScreenView.center = containerView.center
        }) { (success) in
            containerView.layer.cornerRadius = 0
            self.completeTransition(for: transitionContext)
        }

    }
    
}

