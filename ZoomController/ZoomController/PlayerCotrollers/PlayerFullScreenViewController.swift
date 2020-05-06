//
//  PlayerFullScreenViewController.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/30/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

protocol PlayerFullScreenViewControllerDelegate: class {
    func fullScreenChanged(isFullScreen: Bool)
}

protocol PlayerFullScreenViewControllerProtocol: UIViewController, PlayerViewControllerTransitioningProtocol {
    var interactiveTransitionController: FullScreenViewPercentDrivenInteractiveTransition? { get }
    
    var isPresented: Bool { get }
}

class PlayerFullScreenViewController: UIViewController, PlayerFullScreenViewControllerProtocol {
    
    // MARK: Fields
  
    private var playerViewController: PlayerViewControllerProtocol?
    private var originalBackGroundColor: UIColor? = .clear
    
    // MARK: Initializer/Deinitializer
    
    required convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .custom
        interactiveTransitionController = FullScreenViewPercentDrivenInteractiveTransition(interactiveTransitionDelegate: self)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.isUserInteractionEnabled = true
        view.backgroundColor = .black
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
        
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .top
    }
    
    // MARK: PlayerFullScreenViewControllerProtocol
    
    var interactiveTransitionController: FullScreenViewPercentDrivenInteractiveTransition?
    
    var isPresented: Bool {
        return playerViewController != nil
    }
}

extension PlayerFullScreenViewController: PlayerViewControllerTransitioningProtocol {
    func removePlayerViewController() -> PlayerViewControllerProtocol? {
        guard let viewController = playerViewController else {
            return nil
        }

        if let playerView = viewController.view {
            playerView.backgroundColor = originalBackGroundColor
        }
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        playerViewController = nil
        
        return viewController
    }
    
    func movePlayerViewController(_ viewController: PlayerViewControllerProtocol) {
        guard let playerView = viewController.view else {
            return
        }

        originalBackGroundColor = playerView.backgroundColor
        playerView.backgroundColor = view.backgroundColor
        
        viewController.willMove(toParent: nil)
        playerView.removeFromSuperview()
        viewController.removeFromParent()
        addChild(viewController)
        viewController.didMove(toParent: self)
        
        let margin = ThemeManager.shared.currentTheme.contentMargin
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            playerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            playerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            playerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -margin)
        ])
        playerViewController = viewController
    }
    
}

extension PlayerFullScreenViewController: FullScreenViewPercentDrivenInteractiveTransitionDelegate {
    func dismiss() {
        playerViewController?.isFullScreen = false
    }
}
