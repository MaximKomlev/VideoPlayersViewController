//
//  PlayerControlsViewController.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/28/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

protocol PlayerControlsViewDelegate: class {
    func updatePlaybackInfo()
}

protocol PlayerControlsViewControllerProtocol: UIViewController, PlayerControlsViewDelegate {
    var isHidden: Bool { get }
    func show(_ animated: Bool)
    func hide(_ animated: Bool)
    
    var isPlaying: Bool { get set }
    var isFullScreen: Bool { get set }
}

class PlayerControlsViewController: UIViewController,
                                    PlayerControlsViewControllerProtocol {
    
    // MARK: Fields
    
    private let backGroundView = BlurView()
    private let bodyView = PlayerBodyControlsView()
    private let footerView = PlayerFooterControlsView()
    
    private weak var playerDelegate: PlayerViewControllerDelegate?
    
    private var seekingWorkItem: DispatchWorkItem?
    private let seekingRequestTimeout = TimeInterval(1)
    private var isSeeking: Bool = false

    private var layoutConstraints = [NSLayoutConstraint]()

    // MARK: Initializer/Deinitializer
    
    required convenience init(playerDelegate: PlayerViewControllerDelegate) {
        self.init(nibName: nil, bundle: nil)
        
        self.playerDelegate = playerDelegate
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
        
        view.backgroundColor = .clear
        
        backGroundView.translatesAutoresizingMaskIntoConstraints = false
        backGroundView.blurAlpha = 0.4
        backGroundView.isBlurred = true
        view.addSubview(backGroundView)

        bodyView.translatesAutoresizingMaskIntoConstraints = false
        bodyView.isForwardBackwardButtonHidden = true
        bodyView.addPlayButtonTarget(target: self, action: #selector(playButtonEventHandler))
        view.addSubview(bodyView)

        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.addFullScreenButtonTarget(target: self, action: #selector(fullscreenButtonEventHandler))
        footerView.addPlaybackPositionStartTarget(self, action: #selector(sliderPositionStartChangedHandler))
        footerView.addPlaybackPositionTarget(self, action: #selector(sliderPositionChangedHandler))
        footerView.controllsDelegate = self
        view.addSubview(footerView)
        
        makeLayoutConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        makeLayoutConstraints()
    }
    
    // MARK: PlayerControlsViewControllerProtocol
    
    var isHidden: Bool {
        return view.isHidden
    }
    
    func show(_ animated: Bool = true) {
        playerDelegate?.controlsVisibilityChanged(true)
        view.isHidden = false
        if (animated) {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.view.alpha = 1
            }, completion: { (Bool) -> Void in
            })
        } else {
            view.alpha = 1
        }
    }
    
    func hide(_ animated: Bool = true) {
        playerDelegate?.controlsVisibilityChanged(false)
        if (animated) {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.view.alpha = 0
            }, completion: { [weak self] (Bool) -> Void in
                self?.view.isHidden = true
            })
        } else {
            view.isHidden = true
            view.alpha = 0
        }
    }
    
    var isPlaying: Bool = false {
        didSet {
            footerView.isPlaying = isPlaying
            bodyView.isPlaying = isPlaying
        }
    }
    
    var isFullScreen: Bool = false {
        didSet {
            footerView.isFullScreen = isFullScreen
        }
    }
    
    // MARK: Helpers
    
    private func makeLayoutConstraints() {
        NSLayoutConstraint.deactivate(layoutConstraints)
        
        layoutConstraints.removeAll()
        
        let bodyHeight = bodyView.size.height
        let centerYConstraint = bodyView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        centerYConstraint.priority = UILayoutPriority.defaultHigh
        
        let bottomConstraint = bodyView.bottomAnchor.constraint(lessThanOrEqualTo: footerView.topAnchor, constant: 0)
        bottomConstraint.priority = UILayoutPriority.required
        
        layoutConstraints.append(contentsOf: [
            centerYConstraint,
            bodyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            bodyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            bodyView.heightAnchor.constraint(equalToConstant: bodyHeight),
            bottomConstraint
        ])
        
        let footerBottomMargin = isFullScreen ?
            view.window?.safeAreaInsets.bottom ?? CGFloat(20) :
            ThemeManager.shared.currentTheme.itemInsets
        let footerHeight = footerView.size.height
        layoutConstraints.append(contentsOf: [
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            footerView.heightAnchor.constraint(equalToConstant: footerHeight),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -footerBottomMargin)
        ])

        layoutConstraints.append(contentsOf: [
            backGroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            backGroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])

        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    // MARK: Notification & events handlers

    @objc private func playButtonEventHandler(sender: AnyObject) {
        guard let isPlaying = playerDelegate?.isPlaying else {
            return
        }
        playerDelegate?.isPlaying = !isPlaying
        updatePlaybackInfo()
    }
    
    @objc private func sliderPositionStartChangedHandler(sender: UISlider) {
        isSeeking = true
    }
    
    @objc private func sliderPositionChangedHandler(sender: UISlider) {
        seekingWorkItem?.cancel()
        seekingWorkItem = DispatchWorkItem {
            guard !(self.seekingWorkItem?.isCancelled ?? true) else {
                return
            }

            self.playerDelegate?.seek(to: Double(sender.value), completionHandler: { (_) in
                self.isSeeking = false
            })
        }

        if let workItem = seekingWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + seekingRequestTimeout, execute: workItem)
        }
    }
    
    @objc func fullscreenButtonEventHandler(sender: AnyObject) {
        if let playerDelegate = playerDelegate {
            playerDelegate.isFullScreen = !playerDelegate.isFullScreen
        }
    }

}

extension PlayerControlsViewController: PlayerControlsViewDelegate {
    func updatePlaybackInfo() {
        guard !isSeeking, let info = playerDelegate?.fetchPlaybackInfo() else {
            return
        }

        footerView.value = info.value
        footerView.maxValue = info.maxValue
        footerView.minValue = info.minValue
        footerView.rearText = info.rearText
        footerView.frontText = info.frontText
        
        isPlaying = info.isPlaying
    }
}
