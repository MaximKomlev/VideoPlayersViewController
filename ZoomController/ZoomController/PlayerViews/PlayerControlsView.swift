//
//  PlayerControlsView.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/28/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

class PlayerBodyControlsView: UIView {
    
    // MARK: Fields
    
    private let backwardButton = UIButton(type: .system)
    private let playButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
        
    private let defaultButtonSize = CGFloat(48)

    private var isPlaying_ = false
    
    // MARK: Initializers/Deinitializer
   
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        backwardButton.removeTarget(nil, action: nil, for: .touchUpInside)
        playButton.removeTarget(nil, action: nil, for: .touchUpInside)
        forwardButton.removeTarget(nil, action: nil, for: .touchUpInside)
    }
    
    // MARK: View life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frameWidth = bounds.width
        let margin = ThemeManager.shared.currentTheme.contentMargin
        let insets = ThemeManager.shared.currentTheme.itemInsets

        var buttonSize = (frameWidth - 2 * margin - 2 * insets) / 3
        if (buttonSize < defaultButtonSize) {
            buttonSize = defaultButtonSize
        } else if (buttonSize > 100) {
            buttonSize = 100
        }
        
        playButton.bounds = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        forwardButton.bounds = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        backwardButton.bounds = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        let top = insets
        let playbackButtonsWidth = 3 * buttonSize + 2 * insets
        let contentWidth = playbackButtonsWidth + 2 * margin

        playButton.center = CGPoint(x: frameWidth / 2,
                                    y: top + buttonSize / 2)

        if (frameWidth < contentWidth || isForwardBackwardButtonHidden) {
            backwardButton.isHidden = true
            forwardButton.isHidden = true
        } else {
            backwardButton.isHidden = false
            forwardButton.isHidden = false
            
            var x = playButton.center.x - margin - buttonSize / 2
            backwardButton.center = CGPoint(x: x - buttonSize / 2,
                                           y: top + buttonSize / 2)
            
            x = playButton.center.x + margin + buttonSize / 2
            forwardButton.center = CGPoint(x: x + buttonSize / 2,
                                           y: top + buttonSize / 2)
        }
    }
    
    // MARK: Properties
    
    var size: CGSize {
        let frameWidth = bounds.width
        let margin = ThemeManager.shared.currentTheme.contentMargin
        let insets = ThemeManager.shared.currentTheme.itemInsets

        var buttonSize = (frameWidth - 2 * margin - 2 * insets) / 3
        if (buttonSize < defaultButtonSize) {
            buttonSize = defaultButtonSize
        } else if (buttonSize > 100) {
            buttonSize = 100
        }
        return CGSize(width: bounds.width,
                      height: buttonSize + 2 * ThemeManager.shared.currentTheme.itemInsets)
    }
    
    var isPlaying: Bool = false {
        didSet {
            if (isPlaying_ != isPlaying) {
                if (isPlaying) {
                    UIView.animate(withDuration: 0.25, animations: { [weak self] in
                        self?.playButton.alpha = 0
                        }, completion: { (Bool) -> Void in
                            self.playButton.setImage(UIImage(named: "icon_playback_pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
                            self.isPlaying_ = true
                            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                                self?.playButton.alpha = 1
                                }, completion: { (Bool) -> Void in
                            })
                    })
                } else {
                    UIView.animate(withDuration: 0.25, animations: { [weak self] in
                        self?.playButton.alpha = 0
                        }, completion: { (Bool) -> Void in
                            self.playButton.setImage(UIImage(named: "icon_playback_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
                            self.isPlaying_ = false
                            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                                self?.playButton.alpha = 1
                                }, completion: { (Bool) -> Void in
                            })
                    })
                }
            }
        }
    }
    
    var isForwardBackwardButtonHidden: Bool = false {
        didSet {
            if forwardButton.isHidden != isForwardBackwardButtonHidden {
                forwardButton.isHidden = isForwardBackwardButtonHidden
                backwardButton.isHidden = isForwardBackwardButtonHidden
                setNeedsLayout()
            }
        }
    }

    // MARK: Public methods
    
    public func addBackwardButtonTarget(target: Any, action: Selector) {
        backwardButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    public func addPlayButtonTarget(target: Any, action: Selector) {
        playButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    public func addForwardButtonTarget(target: Any, action: Selector) {
        forwardButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    // MARK: Helpers
    
    func initialize() {
        playButton.setImage(UIImage(named: "icon_playback_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
        playButton.tintColor = UIColor.white
        playButton.bounds = CGRect(x: 0, y: 0, width: defaultButtonSize, height: defaultButtonSize)
        playButton.backgroundColor = UIColor.clear
        playButton.showsTouchWhenHighlighted = true
        self.addSubview(playButton)
        
        forwardButton.setImage(UIImage(named: "icon_playback_forward")?.withRenderingMode(.alwaysTemplate), for: .normal)
        forwardButton.tintColor = UIColor.white
        forwardButton.bounds = CGRect(x: 0, y: 0, width: defaultButtonSize, height: defaultButtonSize)
        forwardButton.backgroundColor = UIColor.clear
        forwardButton.showsTouchWhenHighlighted = true
        self.addSubview(forwardButton)
        
        backwardButton.setImage(UIImage(named: "icon_playback_backward")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backwardButton.tintColor = UIColor.white
        backwardButton.bounds = CGRect(x: 0, y: 0, width: defaultButtonSize, height: defaultButtonSize)
        backwardButton.backgroundColor = UIColor.clear
        backwardButton.showsTouchWhenHighlighted = true
        self.addSubview(backwardButton)
    }
    
}

class PlayerFooterControlsView: UIView {
    
    // MARK: Fields
    
    private var infoUpdateInterval: Double = 5
    private let timeInterval: Double = 1
    private var timer: Timer? = nil
    
    private let playbackPositionSlider = SliderView()
    private let playbackPositionLabel = UILabel()
    
    private let playbackPositionHeight: CGFloat = 32
    private let minVisibleWidth: CGFloat = 200

    private let fullScreenButton = UIButton(type: .system)
    
    private let defaultButtonSize: CGFloat = 48
    
    private var isPlaying_ = false
    
    // MARK: Initializers/Deinitializer

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        isPlaying = false
        playbackPositionSlider.removeEventsHandlers()
        fullScreenButton.removeTarget(nil, action: nil, for: .touchUpInside)
    }
    
    // MARK: View life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frameWidth = bounds.width

        let top = ThemeManager.shared.currentTheme.itemInsets
        let margin = ThemeManager.shared.currentTheme.itemInsets
        
        fullScreenButton.bounds = CGRect(origin: CGPoint.zero,
                                         size: CGSize(width: defaultButtonSize, height: defaultButtonSize))
        
        if (frameWidth <= minVisibleWidth) {
            playbackPositionSlider.isHidden = true
            playbackPositionLabel.isHidden = true
            
            fullScreenButton.center = CGPoint(x: frameWidth / 2,
                                              y: top + defaultButtonSize / 2)
        } else {
            playbackPositionSlider.isHidden = false
            playbackPositionLabel.isHidden = false
            
            var labelHeght: CGFloat = 0
            if (!playbackPositionLabel.isHidden) {
                labelHeght = sizeOfString(lable: playbackPositionLabel).height
            }
            
            let maxHeight = max(defaultButtonSize,
                                labelHeght + playbackPositionHeight) + 2 * margin

            fullScreenButton.center = CGPoint(x: frameWidth - margin - defaultButtonSize / 2,
                                              y: top + defaultButtonSize / 2)

            let playbackPositionSliderSize = CGSize(width: frameWidth - 2 * defaultButtonSize,
                                                    height: playbackPositionHeight)
            playbackPositionSlider.bounds = CGRect(origin: CGPoint.zero,
                                                   size: playbackPositionSliderSize)
            playbackPositionSlider.center = CGPoint(x: defaultButtonSize + playbackPositionSliderSize.width / 2,
                                                    y: maxHeight / 2)
            
            playbackPositionSlider.layoutIfNeeded()

            if (isPlaying) {
                controllsDelegate?.updatePlaybackInfo()
            }
        }

        updateOverlayLabel()
    }
    
    // MARK: Properties
    
    var size: CGSize {
        let buttonHeight = fullScreenButton.bounds.height
        var frameHeight = CGFloat(0)

        let frameWidth = bounds.width
        if (frameWidth <= minVisibleWidth) {
            frameHeight = buttonHeight + 2 * ThemeManager.shared.currentTheme.itemInsets
        } else {
            var labelHeght: CGFloat = 0
            if (!playbackPositionLabel.isHidden) {
                labelHeght = sizeOfString(lable: playbackPositionLabel).height
            }
            frameHeight = playbackPositionHeight + labelHeght + 2 * ThemeManager.shared.currentTheme.itemInsets
        }

        return CGSize(width: bounds.width,
                  height: frameHeight)
    }
    
    var isFullScreen: Bool = false {
        didSet {
            if (isFullScreen) {
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.fullScreenButton.alpha = 0
                    }, completion: { (Bool) -> Void in
                        self.fullScreenButton.setImage(UIImage(named: "icon_playback_smallscreen")?.withRenderingMode(.alwaysTemplate), for: .normal)
                        UIView.animate(withDuration: 0.25, animations: { [weak self] in
                            self?.fullScreenButton.alpha = 1
                            }, completion: { (Bool) -> Void in
                        })
                })
            } else {
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.fullScreenButton.alpha = 0
                    }, completion: { (Bool) -> Void in
                        self.fullScreenButton.setImage(UIImage(named: "icon_playback_fullscreen")?.withRenderingMode(.alwaysTemplate), for: .normal)
                        UIView.animate(withDuration: 0.25, animations: { [weak self] in
                            self?.fullScreenButton.alpha = 1
                            }, completion: { (Bool) -> Void in
                        })
                })
            }
        }
    }
    
    weak var controllsDelegate: PlayerControlsViewDelegate?
    
    var formater: GenericFormater = TimePlayBackFormater()
    
    var isPlaying: Bool = false {
        didSet {
            if (isPlaying) {
                if (timer == nil || !timer!.isValid) {
                    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(validateTime), userInfo: nil, repeats: true)
                }
            } else {
                timer?.invalidate()
            }
        }
    }
    
    var showDetailedLabel: Bool {
        get {
            return !playbackPositionLabel.isHidden
        } set (v) {
            if playbackPositionLabel.isHidden != !v {
                playbackPositionLabel.isHidden = !v
            }
        }
    }
    
    var granularity: CGFloat = 1
    
    var value: CGFloat {
        get {
            return CGFloat(playbackPositionSlider.value)
        } set (v) {
            if (playbackPositionSlider.value != v) {
                playbackPositionSlider.value = v
                updateOverlayLabel()
            }
        }
    }
    
    var maxValue: CGFloat {
        get {
            return CGFloat(playbackPositionSlider.maxValue)
        } set (v) {
            if (playbackPositionSlider.maxValue != v) {
                playbackPositionSlider.maxValue = v
            }
        }
    }
    
    var minValue: CGFloat {
        get {
            return CGFloat(playbackPositionSlider.minValue)
        } set (v) {
            if (playbackPositionSlider.minValue != v) {
                playbackPositionSlider.minValue = v
            }
        }
    }
    
    var frontText: String? {
        get {
            return playbackPositionSlider.frontText
        } set (v) {
            if playbackPositionSlider.frontText != v {
                playbackPositionSlider.frontText = v
            }
        }
    }
    
    var rearText: String? {
        get {
            return playbackPositionSlider.rearText
        } set (v) {
            if playbackPositionSlider.rearText != v {
                playbackPositionSlider.rearText = v
            }
        }
    }
    
    // MARK: Public methods
    
    public func addPlaybackPositionTarget(_ target: Any?, action: Selector) {
        playbackPositionSlider.addSliderEventHandler(target, action: action)
    }
    
    public func addPlaybackPositionStartTarget(_ target: Any?, action: Selector) {
        playbackPositionSlider.addSliderStartEventHandler(target, action: action)
    }
    
    public func addPlaybackPositionEndTarget(_ target: Any?, action: Selector) {
        playbackPositionSlider.addSliderEndEventHandler(target, action: action)
    }
    
    public func addFullScreenButtonTarget(target: Any, action: Selector) {
        fullScreenButton.addTarget(target, action: action, for: .touchUpInside)
    }
        
    // MARK: Helpers

    func updatePlaybackPosition() {
        value += 1
    }

    func initialize() {
        playbackPositionSlider.frontRearTextCollor = UIColor.white
        playbackPositionSlider.backgroundColor = UIColor.clear
        playbackPositionSlider.maxValue = 1
        playbackPositionSlider.minValue = 0
        playbackPositionSlider.value = 0
        playbackPositionSlider.addSliderTrackingEventHandler(self, action: #selector(thumbTrackHandler))
        self.addSubview(playbackPositionSlider)
        
        playbackPositionLabel.textColor = UIColor.white
        playbackPositionLabel.font = UIFont.systemFont(ofSize: ThemeManager.shared.currentTheme.fontSizeLabel14)
        playbackPositionLabel.lineBreakMode = .byTruncatingTail
        playbackPositionLabel.numberOfLines = 1
        playbackPositionLabel.textAlignment = .center
        self.addSubview(self.playbackPositionLabel)

        fullScreenButton.setImage(UIImage(named: "icon_playback_fullscreen")?.withRenderingMode(.alwaysTemplate), for: .normal)
        fullScreenButton.tintColor = UIColor.white
        fullScreenButton.bounds = CGRect(x: 0, y: 0, width: defaultButtonSize, height: defaultButtonSize)
        fullScreenButton.backgroundColor = UIColor.clear
        fullScreenButton.showsTouchWhenHighlighted = true
        self.addSubview(fullScreenButton)
    }
    
    func updateOverlayLabel() {
        let thumbRect = playbackPositionSlider.thumbRect
        
        playbackPositionLabel.text = formater.format(value: Double(playbackPositionSlider.value * granularity))
        
        let labelSize = sizeOfString(lable: playbackPositionLabel)
        var labelWidth = labelSize.width
        if (labelWidth > frame.width) {
            labelWidth = frame.width
        }
        
        let x = playbackPositionSlider.frame.origin.x + thumbRect.origin.x + (thumbRect.width - labelWidth) / 2
        let y = playbackPositionSlider.frame.height + 2 * ThemeManager.shared.currentTheme.itemInsets
        
        playbackPositionLabel.frame = CGRect(x: x,
                                              y: y,
                                              width: labelWidth,
                                              height: labelSize.height)
    }
    
    // MARK: Events handlers
    
    @objc func thumbTrackHandler(source: Slider, eventArgs: EventArgs?) {
        updateOverlayLabel()
    }
    
    @objc func validateTime() {
        updatePlaybackPosition()
        if (infoUpdateInterval == 0) {
            controllsDelegate?.updatePlaybackInfo()
            infoUpdateInterval = 5
        }
        infoUpdateInterval -= 1
    }
    
}
