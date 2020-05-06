//
//  PlayerView.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/26/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

protocol PlayerProtocol {
    var isPlaying: Bool { get }
    var url: String { get set }
    var currentPlaybackTime: Double { get }
    var totalPlaybackTime: Double { get }
    
    func play()
    func pause()
    func seek(to time: TimeInterval, completionHandler: @escaping (Bool) -> Void)
}

class PlayerView: UIView, PlayerProtocol {
    
    // MARK: Fields

    private let player = AVPlayer(playerItem: nil)
    private var playerLayer: AVPlayerLayer!
    private var observers = [NSKeyValueObservation?]()
    
    // MARK: Initializer/Deinitializer
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
    }
    
    deinit {}
    
    // MARK: View life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer.frame = bounds
    }
    
    // MARK: PlayerProtocol
    
    weak var delegate: PlayerViewDelegate?
    
    var isPlaying: Bool {
        return player.timeControlStatus == .playing
    }

    var url: String = "" {
        didSet {
            stop()
            if let url = URL(string: url) {
                player.replaceCurrentItem(with: AVPlayerItem(url: url))
                startObservers()
            }
        }
    }
    
    func play() {
        player.volume = 1.0
        player.play()
    }

    func pause() {
        player.pause()
    }
    
    func seek(to time: TimeInterval, completionHandler: @escaping (Bool) -> Void) {
        if currentPlaybackTime != time {
            let time = CMTime(seconds: time, preferredTimescale: 1)
            player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { (result) in
                completionHandler(result)
                self.onPlaying()
            }
        }
    }

    var currentPlaybackTime: Double {
        return player.currentTime().seconds
    }

    var totalPlaybackTime: Double {
        guard let duration = player.currentItem?.asset.duration else {
            return 0
        }
        return CMTimeGetSeconds(duration)
    }

    // MARK: KVO
    
    func startObservers() {
        let statusObsever = player.observe(\.status, options: [.new]) { [weak self] (player, _) in
            guard let this = self else {
                return
            }
            if player.status == AVPlayer.Status.failed || player.status == AVPlayer.Status.unknown {
                this.onPaused()
            } else {
                print("AVPlayer status \(String(describing: player.status))")
            }
        }
        observers.append(statusObsever)

        let statusTimeControlStatusObsever = player.observe(\.timeControlStatus, options: [.new]) { [weak self] (player, _) in
            guard let this = self else {
                return
            }

            if player.timeControlStatus == .playing {
                this.onPlaying()
            } else if player.timeControlStatus == .paused {
                this.onPaused()
            } else {
            }
        }
        observers.append(statusTimeControlStatusObsever)

        let resolutionChangeObsever = player.observe(\.currentItem?.presentationSize, options: [.initial, .new]) { [weak self] (player, _) in
            guard let this = self else {
                return
            }
            this.onVideoResolution()
        }
        observers.append(resolutionChangeObsever)

        NotificationCenter.default.addObserver(self, selector: #selector(playerFinishedPlayingHandler), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    func stopObservers() {
        observers.forEach({ observer in
            observer?.invalidate()
        })
        observers.removeAll()

        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Helpers
    
    private func initialize() {
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        layer.addSublayer(playerLayer)
    }
    
    private func stop() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        stopObservers()
    }
        
    private func onPlaying() {
        delegate?.playing(player: self)
    }

    private func onPaused() {
        delegate?.paused(player: self)
    }

    private func onInterrupted() {
        delegate?.interrupted(player: self)
    }
        
    private func onVideoResolution() {
        delegate?.videoResolutionChanged(player: self)
    }
    
    private func onEnd() {
        delegate?.ended(player: self)
    }
    
    // MARK: Notification & events handlers
    
    @objc private func playerFinishedPlayingHandler() {
        onEnd()
    }
    
}
