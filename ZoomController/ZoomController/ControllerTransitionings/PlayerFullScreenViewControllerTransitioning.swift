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

        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        containerView.backgroundColor = fullScreenView.backgroundColor
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = ThemeManager.shared.currentTheme.cornerRadius
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 0
        containerView.layer.masksToBounds = true

        containerView.addSubview(fullScreenView)
        fullScreenView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fullScreenView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 0),
            fullScreenView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            fullScreenView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            fullScreenView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        containerView.center = viewController.view.convert(transitioningCoordinator.initialViewRect().origin,
                                                           from: transitioningCoordinator.initialView())
        containerView.bounds.size = transitioningCoordinator.initialViewRect().size

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic, .layoutSubviews], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1) {
                containerView.bounds = fullScreenView.window?.bounds ?? UIScreen.main.bounds
                containerView.center = fullScreenView.window?.center ?? CGPoint(x: UIScreen.main.bounds.width / 2,
                                                                                y: UIScreen.main.bounds.height / 2)
            }
        }) { (success) in
            containerView.layer.cornerRadius = 0
            transitionContext.completeTransition(true)
        }

    }
    
}
