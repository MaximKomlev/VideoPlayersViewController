//
//  PlayerViewControllerTransitioningCoordinator.swift
//  ZoomController
//
//  Created by Maxim Komlev on 5/5/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

protocol PlayerViewControllerTransitioningCoordinatorDelegate: class {
    func fullScreenChanged(source: PlayerViewControllerProtocol)
}

protocol PlayerViewControllerTransitioningControllerProtocol: UIViewController {
    func isPresented() -> Bool
    func playerViewRect() -> CGRect
    func removePlayerViewController() -> PlayerViewControllerProtocol?
    func movePlayerViewController(_ viewController: PlayerViewControllerProtocol)
}

protocol PlayerViewControllerTransitioningCoordinatorProtocol: class {
    init(playerViewController: PlayerViewControllerProtocol,
         widgetViewController: PlayerViewControllerTransitioningControllerProtocol,
         fullScreenViewController: PlayerViewControllerTransitioningControllerProtocol)
    
    func initialViewRect() -> CGRect
    func initialView() -> UIView

    func transitionFinished(controllerTransitioning: BaseViewControllerTransitioning, wasCancelled: Bool)
}

class PlayerViewControllerTransitioningCoordinator: NSObject {

    // MARK: Fields
    
    private unowned var playerViewController: PlayerViewControllerProtocol!

    private unowned var widgetViewController: PlayerViewControllerTransitioningControllerProtocol!
    private unowned var fullScreenViewController: PlayerViewControllerTransitioningControllerProtocol!
    
    private var interactiveTransitionController: PlayerFullScreenViewInteractiveTransition!

    // MARK: Initializers/Deinitializer
    
    required init(playerViewController: PlayerViewControllerProtocol,
                  widgetViewController: PlayerViewControllerTransitioningControllerProtocol,
                  fullScreenViewController: PlayerViewControllerTransitioningControllerProtocol) {
        super.init()
        self.playerViewController = playerViewController
        self.playerViewController.transitioningCoordinatorDelegate = self
        self.widgetViewController = widgetViewController
        self.fullScreenViewController = fullScreenViewController
        self.fullScreenViewController.transitioningDelegate = self
        self.interactiveTransitionController = PlayerFullScreenViewInteractiveTransition(playerFullScreenViewController: self.fullScreenViewController)
        self.interactiveTransitionController.interactiveTransitionDelegate = self
    }
}

// MARK: SourceViewPlayerViewControllerTransitioningProtocol

extension PlayerViewControllerTransitioningCoordinator: PlayerViewControllerTransitioningCoordinatorProtocol {
    func initialViewRect() -> CGRect {
        return widgetViewController.playerViewRect()
    }
    
    func initialView() -> UIView {
        return widgetViewController.view
    }
    
    func transitionFinished(controllerTransitioning: BaseViewControllerTransitioning, wasCancelled: Bool) {
        guard !wasCancelled, !controllerTransitioning.isFullScreenDirection else {
            playerViewController.isFullScreen = true
            return
        }
        
        if let vc = fullScreenViewController?.removePlayerViewController() {
            widgetViewController.movePlayerViewController(vc)
        }
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension PlayerViewControllerTransitioningCoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if let vc = widgetViewController.removePlayerViewController() {
            fullScreenViewController?.movePlayerViewController(vc)
        }
        
        return PlayerFullScreenViewControllerTransitioning(coordinator: self)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PlayerWidgetViewControllerTransitioning(coordinator: self)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard fullScreenViewController.isPresented(),
            interactiveTransitionController.isRunning else {
            return nil
        }
        return interactiveTransitionController
    }

}

// MARK: PlayerFullScreenViewInteractiveTransitionDelegate

extension PlayerViewControllerTransitioningCoordinator: PlayerFullScreenViewInteractiveTransitionDelegate {
    func dismiss() {
        playerViewController?.isFullScreen = false
    }
}

// MARK: PlayerViewControllerTransitioningCoordinatorDelegate

extension PlayerViewControllerTransitioningCoordinator: PlayerViewControllerTransitioningCoordinatorDelegate {
    func fullScreenChanged(source: PlayerViewControllerProtocol) {
        if source.isFullScreen {
            guard !fullScreenViewController.isPresented() else {
                return
            }
            widgetViewController.present(fullScreenViewController, animated: true)
        } else {
            fullScreenViewController?.dismiss(animated: true)
        }
    }
}
