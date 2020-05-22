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
         widgetViewController: PlayerViewControllerTransitioningControllerProtocol)
    
    func initialViewRect(at viewController: UIViewController) -> CGRect

    func isRotationNeeded() -> Bool
    
    func transitionStarted(controllerTransitioning: BaseViewControllerTransitioning)
    func transitionFinished(controllerTransitioning: BaseViewControllerTransitioning, wasCancelled: Bool)
}

class PlayerViewControllerTransitioningCoordinator: NSObject {

    // MARK: Fields
    
    private unowned var widgetViewController: PlayerViewControllerTransitioningControllerProtocol!

    private unowned var playerViewController: PlayerViewControllerProtocol!

    private var fullScreenViewController: PlayerFullScreenViewControllerProtocol!
    private var fullScreenTransitioningWindow: PlayerFullScreenTransitioningWindow?
    private var interactiveTransitionController: PlayerFullScreenViewInteractiveTransition!

    // MARK: Initializers/Deinitializer
    
    required init(playerViewController: PlayerViewControllerProtocol,
                  widgetViewController: PlayerViewControllerTransitioningControllerProtocol) {
        super.init()
        self.playerViewController = playerViewController
        self.playerViewController.transitioningCoordinatorDelegate = self
        self.widgetViewController = widgetViewController
        self.fullScreenViewController = PlayerFullScreenViewController()
        self.fullScreenViewController.transitioningDelegate = self
        self.interactiveTransitionController = PlayerFullScreenViewInteractiveTransition(playerFullScreenViewController: self.fullScreenViewController)
        self.interactiveTransitionController.interactiveTransitionDelegate = self
    }
    
    // MARK: Helpers
    
    private func isFullScreen() -> Bool {
        return fullScreenTransitioningWindow != nil || fullScreenViewController.isPresented()
    }
    
    private func isTransitioningWindowNedded() -> Bool {
        if UIScreen.main.traitCollection.horizontalSizeClass == .regular,
            UIScreen.main.traitCollection.verticalSizeClass == .regular {
            return false
        } else {
            return true
        }
    }
    
    private func present() {
        guard let windowScene = widgetViewController.view.window?.windowScene else {
            return
        }
        if isTransitioningWindowNedded() {
            fullScreenTransitioningWindow = PlayerFullScreenTransitioningWindow(windowScene: windowScene)
            fullScreenTransitioningWindow?.windowLevel = .normal
            fullScreenTransitioningWindow?.isHidden = false
            fullScreenTransitioningWindow?.rootViewController?.present(fullScreenViewController, animated: true)
            fullScreenTransitioningWindow?.makeKeyAndVisible()
        } else {
            widgetViewController?.present(fullScreenViewController, animated: true)
        }
    }
    
    private func dismiss() {
        fullScreenViewController?.dismiss(animated: true)
    }
    
}

// MARK: SourceViewPlayerViewControllerTransitioningProtocol

extension PlayerViewControllerTransitioningCoordinator: PlayerViewControllerTransitioningCoordinatorProtocol {
    func initialViewRect(at viewController: UIViewController) -> CGRect {
        let coordinateSpaceView = widgetViewController.view.window ?? viewController.view
        return coordinateSpaceView?.convert(widgetViewController.playerViewRect(), from: widgetViewController.view) ?? CGRect.zero
    }
    
    func isRotationNeeded() -> Bool {
        if !isTransitioningWindowNedded() {
            return false
        }
        
        let screenResolution = fullScreenTransitioningWindow?.bounds.size ?? UIScreen.main.bounds.size
        if screenResolution.width < screenResolution.height {
            return false
        }
        
        return true
    }
    
    func transitionStarted(controllerTransitioning: BaseViewControllerTransitioning) {
        guard controllerTransitioning.isFullScreenDirection else {
            return
        }
        
        if let vc = widgetViewController.removePlayerViewController() {
            fullScreenViewController?.movePlayerViewController(vc)
        }
    }
    
    func transitionFinished(controllerTransitioning: BaseViewControllerTransitioning, wasCancelled: Bool) {
        if wasCancelled && !controllerTransitioning.isFullScreenDirection {
            playerViewController.isFullScreen = true
            return
        }
        
        if !controllerTransitioning.isFullScreenDirection {
            if let vc = fullScreenViewController?.removePlayerViewController() {
                widgetViewController.movePlayerViewController(vc)
            }

            fullScreenTransitioningWindow?.isHidden = true
            fullScreenTransitioningWindow?.rootViewController = nil
            fullScreenTransitioningWindow = nil

            widgetViewController.view.window?.makeKeyAndVisible()
        }
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension PlayerViewControllerTransitioningCoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PlayerFullScreenViewControllerTransitioning(coordinator: self)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PlayerWidgetViewControllerTransitioning(coordinator: self)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard isFullScreen(),
            interactiveTransitionController.isRunning else {
            return nil
        }
        return interactiveTransitionController
    }

}

// MARK: PlayerFullScreenViewInteractiveTransitionDelegate

extension PlayerViewControllerTransitioningCoordinator: PlayerFullScreenViewInteractiveTransitionDelegate {
    func tryDismiss() {
        playerViewController?.isFullScreen = false
    }
}

// MARK: PlayerViewControllerTransitioningCoordinatorDelegate

extension PlayerViewControllerTransitioningCoordinator: PlayerViewControllerTransitioningCoordinatorDelegate {
    func fullScreenChanged(source: PlayerViewControllerProtocol) {
        if source.isFullScreen {
            guard !isFullScreen() else {
                return
            }
            
            present()
        } else {
            dismiss()
        }
    }
}
