//
//  FullScreenViewPercentDrivenInteractiveTransition.swift
//  ZoomController
//
//  Created by Maxim Komlev on 5/3/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

protocol FullScreenViewPercentDrivenInteractiveTransitionDelegate: UIViewController {
    func dismiss()
}

class FullScreenViewPercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {

    // MARK: Fields
    
    private weak var interactiveTransitionDelegate: FullScreenViewPercentDrivenInteractiveTransitionDelegate?
    private let panGestureRecognizer = UIPanGestureRecognizer()

    // MARK: Initializer/Deinitializer

    init(interactiveTransitionDelegate: FullScreenViewPercentDrivenInteractiveTransitionDelegate) {
        super.init()
        
        self.interactiveTransitionDelegate = interactiveTransitionDelegate
        self.interactiveTransitionDelegate?.view.isUserInteractionEnabled = true

        self.panGestureRecognizer.addTarget(self, action: #selector(panHandler))
        self.interactiveTransitionDelegate?.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: Properties
    
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
