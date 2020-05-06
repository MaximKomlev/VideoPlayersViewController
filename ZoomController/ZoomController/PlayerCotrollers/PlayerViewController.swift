//
//  PlayerViewController.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/27/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

struct PlaybackInfo {
    var maxValue: CGFloat = 0
    var minValue: CGFloat = 0
    var value: CGFloat = 0

    var frontText: String? = nil
    var rearText: String? = nil
    
    var isPlaying: Bool = false
}

protocol PlayerViewControllerProtocol: UIViewController {
    var transitioningCoordinatorDelegate: PlayerViewControllerTransitioningCoordinatorDelegate? { get set }

    var videoUrl: String { get set }
    var isPlaying: Bool { get set }
    var isFullScreen: Bool { get set }

    func seek(to time: Double, completionHandler: @escaping (Bool) -> Void)
}

protocol PlayerViewControllerDelegate: PlayerViewControllerProtocol {
    func fetchPlaybackInfo() -> PlaybackInfo
    func controlsVisibilityChanged(_ visible: Bool)
}

protocol PlayerViewDelegate: class {
    func playing(player: PlayerProtocol)
    func paused(player: PlayerProtocol)
    func interrupted(player: PlayerProtocol)
    func videoResolutionChanged(player: PlayerProtocol)
    func ended(player: PlayerProtocol)
}

class PlayerViewController: UIViewController, PlayerViewControllerProtocol {
    
    // MARK: Fields
  
    private let playerView = PlayerView()
    private var zoomViewController: ZoomViewControllerProtocol!
    private var playerControlsViewController: PlayerControlsViewControllerProtocol!

    private let tapGestureRecogniser = UITapGestureRecognizer()
    
    private var timer: Timer? = nil
    private let timeInterval: Double = 5

    // MARK: Initializer/Deinitializer
    
    required convenience init() {
        self.init(nibName: nil, bundle: nil)
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

        view.isUserInteractionEnabled = true

        var zoomConfig = ZoomViewControllerConfig()
        zoomConfig.maxZoom = 16
        zoomViewController = ZoomViewController(delegate: self, zoomConfig: zoomConfig)

        playerView.delegate = self
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        zoomViewController.setPlayerView(playerView)
        zoomViewController.viewDidLoad(view)

        tapGestureRecogniser.addTarget(self, action: #selector(tapAction(_:)))
        tapGestureRecogniser.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecogniser)

        playerControlsViewController = PlayerControlsViewController(playerDelegate: self)
        if let controlsView = playerControlsViewController.view {
            addChild(playerControlsViewController)
            playerControlsViewController.didMove(toParent: self)
            view.addSubview(controlsView)

            controlsView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                controlsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                controlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            ])
        }
        
        playerControlsViewController.show(false)
        resetTimerFooterVisibility()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        zoomViewController.viewDidResize(view.bounds.size)
    }

    // MARK: PlayerViewControllerProtocol

    var isFullScreen: Bool = false {
        didSet {
            transitioningCoordinatorDelegate?.fullScreenChanged(isFullScreen: isFullScreen)
            playerControlsViewController.isFullScreen = isFullScreen
        }
    }
    
    var isPlaying: Bool = false {
        didSet {
            guard playerView.isPlaying != isPlaying else {
                return
            }
            if isPlaying {
                playerView.play()
            } else {
                playerView.pause()
            }
        }
    }
    
    var videoUrl: String {
        get {
            return playerView.url
        } set (v) {
            if playerView.url != v {
                playerView.url = v
            }
        }
    }
    
    weak var transitioningCoordinatorDelegate: PlayerViewControllerTransitioningCoordinatorDelegate?
    
    func seek(to time: Double, completionHandler: @escaping (Bool) -> Void) {
        playerView.seek(to: time) { (result) in
            completionHandler(result)
        }
    }
    
    // MARK: Helpers
    
    private func resetTimerFooterVisibility() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                     target: self,
                                     selector: #selector(validateTime),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    private func invalidateTimerFooterVisibility() {
        timer?.invalidate()
    }
    
    // MARK: Notification & events handlers

    @objc private func validateTime() {
        playerControlsViewController.hide(true)
    }
            
    @objc private func tapAction(_ sender: UITapGestureRecognizer) {
        if playerControlsViewController.isHidden {
            playerControlsViewController.show(true)
            zoomViewController.isTrackerHidden = true
        } else {
            playerControlsViewController.hide(true)
        }
        resetTimerFooterVisibility()
    }
    
}

// MARK: ZoomViewControllerDelegate

extension PlayerViewController: ZoomViewControllerDelegate {
    func startPlayerRectChang(source: ZoomViewControllerProtocol) {
    }
    
    func stopPlayerRectChang(source: ZoomViewControllerProtocol) {
    }
}

// MARK: PlayerViewControllerDelegate

extension PlayerViewController: PlayerViewControllerDelegate {
    func fetchPlaybackInfo() -> PlaybackInfo {
        let duration = playerView.totalPlaybackTime
        let currentPosition = playerView.currentPlaybackTime
        let info = PlaybackInfo(maxValue: CGFloat(duration),
                                minValue: 0,
                                value: CGFloat(currentPosition),
                                rearText: timeFormater("hh:mm:ss", tm: duration),
                                isPlaying: playerView.isPlaying)
        
        return info
    }
            
    func controlsVisibilityChanged(_ visible: Bool) {
        zoomViewController.isZoomingEnabled = !visible
    }
}

// MARK: PlayerViewDelegate

extension PlayerViewController: PlayerViewDelegate {
    func playing(player: PlayerProtocol) {
        playerControlsViewController.show(true)
        playerControlsViewController.updatePlaybackInfo()
        resetTimerFooterVisibility()
    }
    
    func paused(player: PlayerProtocol) {
        playerControlsViewController.updatePlaybackInfo()
    }
    
    func interrupted(player: PlayerProtocol) {
        playerControlsViewController.updatePlaybackInfo()
    }
    
    func videoResolutionChanged(player: PlayerProtocol) {
    }
    
    func ended(player: PlayerProtocol) {
        player.seek(to: 0, completionHandler: {_ in })
        playerControlsViewController.updatePlaybackInfo()
    }
}
