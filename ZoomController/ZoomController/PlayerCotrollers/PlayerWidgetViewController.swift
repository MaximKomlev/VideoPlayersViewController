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
    
    var isPlaying: Bool { get }
    var isFullScreen: Bool { get set }
}

class PlayerWidgetViewController: UIViewController {
    
    // MARK: Fields
    
    private let infoViewHeight = CGFloat(100)
    
    private let widgetView = PlayerWidgetView()
    private var playerViewController: PlayerViewControllerProtocol!
    private var transitioningCoordinator: PlayerViewControllerTransitioningCoordinatorProtocol!
    
    // MARK: Initializer/Deinitializer
    
    required convenience init(model: VideoItem) {
        self.init(nibName: nil, bundle: nil)
                
        widgetView.videoContentSize = model.resolution
        widgetView.captionAttributedText = NSAttributedString(string: model.title ?? "")
        widgetView.descriptionAttributedText = NSAttributedString(string: model.description ?? "")
        widgetView.isBorder = true
        
        playerViewController = PlayerViewController()
        playerViewController.videoUrl = model.videoUrl ?? ""
        
        transitioningCoordinator = PlayerViewControllerTransitioningCoordinator(playerViewController: playerViewController,
                                                                                widgetViewController: self)
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
    
    // MARK: PlayerWidgetViewControllerProtocol
    
    var isPlaying: Bool {
        return playerViewController.isPlaying
    }
    
    var isFullScreen: Bool {
        get {
            return playerViewController.isFullScreen
        } set (v) {
            if playerViewController.isFullScreen != v {
                playerViewController.isFullScreen = v
            }
        }
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

// MARK: PlayerViewControllerTransitioningProtocol

extension PlayerWidgetViewController: PlayerViewControllerTransitioningControllerProtocol {
    func isPresented() -> Bool {
        return playerViewController != nil
    }

    func playerViewRect() -> CGRect {
        return widgetView.videoContentRect
    }
    
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
        addChild(viewController)
        viewController.didMove(toParent: self)
        widgetView.addPlayerView(viewController.view)
    }
}
