//
//  PlayerFullScreenViewController.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/30/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

protocol PlayerFullScreenViewControllerProtocol: PlayerViewControllerTransitioningControllerProtocol {
}

class PlayerFullScreenViewController: UIViewController {
    
    // MARK: Fields
  
    private unowned var playerViewController: PlayerViewControllerProtocol?
    private var originalBackGroundColor: UIColor? = .clear
    
    // MARK: Initializer/Deinitializer
    
    required convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .custom
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
        
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .top
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var shouldAutorotate: Bool {
        return true
    }
            
}

extension PlayerFullScreenViewController: PlayerFullScreenViewControllerProtocol {
}

extension PlayerFullScreenViewController: PlayerViewControllerTransitioningControllerProtocol {
    func playerViewRect() -> CGRect {
        return playerViewController?.view.frame ?? CGRect.zero
    }

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
        
        addChild(viewController)
        viewController.didMove(toParent: self)
        
        view.addSubview(playerView)
        playerView.bounds.size = view.bounds.size
        playerView.center = view.center
        playerView.translatesAutoresizingMaskIntoConstraints = true
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerViewController = viewController
    }
    
}

