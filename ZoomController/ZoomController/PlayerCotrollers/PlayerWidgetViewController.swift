//
//  PlayerWidgetViewController.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/28/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

protocol PlayerWidgetViewControllerProtocol: UIViewController {
    func sizeConstrained(to width: CGFloat) -> CGSize
}

class PlayerWidgetViewController: UIViewController {
    
    // MARK: Fields
    
    private let infoViewHeight = CGFloat(100)
    
    private let widgetView = PlayerWidgetView()
    private var playerViewController: PlayerViewControllerProtocol!
    private var fullScreenViewController: PlayerFullScreenViewControllerProtocol!
    
    // MARK: Initializer/Deinitializer
    
    required convenience init(model: VideoItem) {
        self.init(nibName: nil, bundle: nil)
        
        providesPresentationContextTransitionStyle = true
        
        widgetView.videoContentSize = model.resolution
        widgetView.captionAttributedText = NSAttributedString(string: model.title ?? "")
        widgetView.descriptionAttributedText = NSAttributedString(string: model.description ?? "")
        widgetView.isBorder = true
        
        playerViewController = PlayerViewController()
        playerViewController.fullScreenDelegate = self
        playerViewController.videoUrl = model.videoUrl ?? ""
        
        fullScreenViewController = PlayerFullScreenViewController()
        fullScreenViewController.transitioningDelegate = self
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        movePlayerViewController(playerViewController)

        view.addSubview(widgetView)
        widgetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widgetView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            widgetView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            widgetView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            widgetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    var isFullScreen: Bool {
        return fullScreenViewController != nil
    }
    
    // MARK: SourceViewPlayerViewControllerTransitioningProtocol
    
    var sourceRect: CGRect {
        return widgetView.videoContentRect
    }
    
}

// MARK: PlayerWidgetViewControllerProtocol

extension PlayerWidgetViewController: PlayerWidgetViewControllerProtocol {
    func sizeConstrained(to width: CGFloat) -> CGSize {
        if width < widgetView.videoContentSize.width {
            let ratio = widgetView.videoContentSize.height / widgetView.videoContentSize.width
            widgetView.videoContentSize = CGSize(width: width, height: width * ratio)
        }
        return CGSize(width: widgetView.videoContentSize.width,
                      height: widgetView.videoContentSize.height + infoViewHeight)
    }
}

// MARK: SourceViewPlayerViewControllerTransitioningProtocol

extension PlayerWidgetViewController: SourceViewPlayerViewControllerTransitioningProtocol {
    func transitionFinished(controllerTransitioning: BaseViewControllerTransitioning, wasCancelled: Bool) {
        guard !wasCancelled, !controllerTransitioning.isFullScreenDirection else {
            playerViewController.isFullScreen = true
            return
        }
        
        if let vc = fullScreenViewController?.removePlayerViewController() {
            movePlayerViewController(vc)
        }
    }
}

// MARK: PlayerFullScreenViewControllerDelegate

extension PlayerWidgetViewController: PlayerFullScreenViewControllerDelegate {
    func fullScreenChanged(isFullScreen: Bool) {
        if isFullScreen {
            guard !fullScreenViewController.isPresented else {
                return
            }
            present(fullScreenViewController, animated: true)
        } else {
            fullScreenViewController?.dismiss(animated: true)
        }
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension PlayerWidgetViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if let vc = removePlayerViewController() {
            fullScreenViewController?.movePlayerViewController(vc)
        }
        
        return FullScreenViewControllerTransitioning(source: self)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PlayerWidgetViewControllerTransitioning(source: self)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
        guard let interactiveTransitionController = fullScreenViewController?.interactiveTransitionController,
            interactiveTransitionController.isRunning else {
                return nil
        }
        return interactiveTransitionController
    }

}

// MARK: PlayerViewControllerTransitioningProtocol

extension PlayerWidgetViewController: PlayerViewControllerTransitioningProtocol {
    func removePlayerViewController() -> PlayerViewControllerProtocol? {
        guard let viewController = playerViewController else {
            return nil
        }

        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        
        return viewController
    }

    func movePlayerViewController(_ viewController: PlayerViewControllerProtocol) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        addChild(viewController)
        viewController.didMove(toParent: self)
        widgetView.addPlayerView(viewController.view)
    }
}
