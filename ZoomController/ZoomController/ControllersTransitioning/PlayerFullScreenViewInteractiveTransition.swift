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
    func dismiss()
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
        if point.y > 0 && point.y < 100 {
            return true
        }
        return false
    }
    
    // MARK: Notification & events handlers

    @objc private func panHandler(sender: UIPanGestureRecognizer) {
        guard let view = sender.view else {
            return
        }

        let offset = sender.translation(in: view)
        let percent = offset.y / view.bounds.height
        
        switch sender.state {
        case .began:
            let beginPosition = sender.location(in: view)
            if validatePanEdge(point: beginPosition) {
                isRunning = true
                interactiveTransitionDelegate?.dismiss()
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
