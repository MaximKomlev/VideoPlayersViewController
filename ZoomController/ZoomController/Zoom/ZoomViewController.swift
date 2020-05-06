//
//  ZoomViewController.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/24/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

private extension UIImage {
    func alpha(_ value: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

private extension UIView {
    
    // pre transform frame
    var originalFrame: CGRect {
        let currentTransform = transform
        transform = .identity
        let originalFrame = frame
        transform = currentTransform
        return originalFrame
    }
    
    // point offset from center
    func centerOffset(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: (point.x - center.x),
                       y: (point.y - center.y))
    }

    // point back relative to center
    func pointRelativeToCenter(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: (point.x + center.x),
                       y: (point.y + center.y))
    }

    // point relative to transformed coords
    func transformedPointInView(_ point: CGPoint) -> CGPoint {
        let offset = centerOffset(point)
        let transformedPoint = offset.applying(transform)
        return pointRelativeToCenter(CGPoint(x: transformedPoint.x,
                                             y: transformedPoint.y))
    }

    // point in transformed coords
    var transformedOrigin: CGPoint {
        return transformedPointInView(originalFrame.origin)
    }

    // size in transformed coords
    var transformedSize: CGSize {
        let newSize = originalFrame.size.applying(transform)
        return CGSize(width: newSize.width,
                      height: newSize.height)
    }

    func takeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension CGAffineTransform {
    var scalePoint: CGPoint {
        let xScale = sqrt(self.a * self.a + self.c * self.c)
        let yScale = sqrt(self.b * self.b + self.d * self.d)
        return CGPoint(x: xScale, y: yScale)
    }

    var scaleTransform: CGAffineTransform {
        let scale = scalePoint
        return CGAffineTransform(scaleX: scale.x, y: scale.y)
    }

    var rotationAngle: CGFloat {
        return CGFloat(atan2(self.b, self.a))
    }

    var rotationTransform: CGAffineTransform {
        let angle = rotationAngle
        return CGAffineTransform(rotationAngle: angle)
    }

    var translationPoint: CGPoint {
        return CGPoint(x: self.tx, y: self.ty)
    }

    var translationTransform: CGAffineTransform {
        let translation = translationPoint
        return CGAffineTransform(translationX: translation.x, y: translation.y)
    }
}

extension CGFloat {
    func round(to precision: Int) -> CGFloat {
        let divisor = pow(10.0, Double(precision))
        return CGFloat((Double(self) * divisor).rounded() / divisor)
    }
}

private let animationDuration = 0.375
private let requestTimeout = 3.0
private let zoomFrameTrackerPadding: CGFloat = 16
private let cameraCropBorderWidth: CGFloat = 2

struct ZoomViewControllerConfig {
    var scaleVelocity: CGFloat = 0.8
    var scalePrecision: CGFloat = 0.1
    var minZoom: CGFloat = 1
    var maxZoom: CGFloat = 16
    
    fileprivate(set) var videoRatio: CGFloat =  9 / 16
}

protocol ZoomViewControllerDelegate: class {
    func startPlayerRectChang(source: ZoomViewControllerProtocol)
    func stopPlayerRectChang(source: ZoomViewControllerProtocol)
}

protocol ZoomViewControllerProtocol {
    init(delegate: ZoomViewControllerDelegate, zoomConfig: ZoomViewControllerConfig)
    
    func viewDidLoad(_ view: UIView)
    func viewDidResize(_ size: CGSize)
    
    @discardableResult
    func setPlayerView(_ view: UIView) -> Bool
    func makeBackgoundImage()
    func updatePlayerView(zoomInfo: ZoomInfo)
    func updatePlayerView(ratio: CGFloat)
    func zoomInfo() -> ZoomInfo
    func videoThumbnail() -> UIImage?
    func viewSnapshot() -> UIImage?
    func playerResolution() -> CGSize
    func reset()
    
    var currentZoom: CGFloat { get }
    var isZoomingEnabled: Bool { get set }
    var isTrackerHidden: Bool { get set }
    var hideTrackerOnIdle: Bool { get set }
    var clipToCrop: Bool { get set }
}

@objc class ZoomViewController: NSObject,
                                     ZoomViewControllerProtocol,
                                     UIGestureRecognizerDelegate {
    
    // MARK: Fields

    private var workItemToHideTracker: DispatchWorkItem?

    private let contentView = UIView()
    private let cropView = UIView()
    private let playerHolderView = UIImageView()
    private let playerView = UIView()
    private let frameTrackerView = ZoomTrackerView()
    private var frameTrackerViewWidthConstraint = NSLayoutConstraint()
    
    private let pinchGesture = UIPinchGestureRecognizer()
    private let panGesture = UIPanGestureRecognizer()
    
    private var zoomConfig = ZoomViewControllerConfig()

    private weak var delegate: ZoomViewControllerDelegate?

    // MARK: Initializers/Deinitializer
    
    required init(delegate: ZoomViewControllerDelegate,
                  zoomConfig: ZoomViewControllerConfig = ZoomViewControllerConfig()) {
        self.delegate = delegate
        self.zoomConfig = zoomConfig
    }

    // MARK: ZoomViewControllerProtocol
        
    // call the method when loading
    func viewDidLoad(_ view: UIView) {
        view.addSubview(contentView)
        
        contentView.clipsToBounds = true
        contentView.isUserInteractionEnabled = true
        contentView.addSubview(cropView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])

        // cropView view to hold draggable and scalable view
        let size = view.bounds.size
        let center = view.center

        cropView.backgroundColor = .clear

        // playerHolderView to scale and drag inside of cropView
        playerHolderView.image = nil
        playerHolderView.contentMode = .scaleAspectFit
        playerHolderView.backgroundColor = .clear
        cropView.addSubview(playerHolderView)

        // playerView to hold player view
        playerView.contentMode = .scaleAspectFit
        playerView.backgroundColor = .clear
        playerView.clipsToBounds = false
        playerHolderView.addSubview(playerView)

        playerView.layer.borderWidth = 0
        playerView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor

        reBounds(to: size, center: center)

        frameTrackerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(frameTrackerView)
        frameTrackerViewWidthConstraint = frameTrackerView.heightAnchor.constraint(equalTo: frameTrackerView.widthAnchor,
                                                                                   multiplier: zoomConfig.videoRatio)
        NSLayoutConstraint.activate([
            frameTrackerView.widthAnchor.constraint(equalToConstant: ZoomTrackerViewConfig.witdth),
            frameTrackerViewWidthConstraint,
            frameTrackerView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: zoomFrameTrackerPadding),
            frameTrackerView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -zoomFrameTrackerPadding)
        ])
        frameTrackerView.trackingFrame = CGRect(origin: CGPoint.zero,
                                                size: CGSize(width: ZoomTrackerViewConfig.witdth,
                                                             height: ZoomTrackerViewConfig.witdth * zoomConfig.videoRatio))
        isTrackerHidden = true

        pinchGesture.addTarget(self, action: #selector(pinchHandler))
        panGesture.addTarget(self, action: #selector(panHandler))
        panGesture.delegate = self
    }
    
    // call the method when view resizing/rotated
    func viewDidResize(_ size: CGSize) {
        // calculate new size of parrent according to default view ratio
        let newSize = validateSizeToPlayerRatio(of: size)
                
        let newCenter = CGPoint(x: contentView.bounds.width / 2,
                                y: contentView.bounds.height / 2)

        // calculate adjustment scale
        let adjustmentScale = CGPoint(x: newSize.width / cropView.bounds.width,
                                      y: newSize.height / cropView.bounds.height)

        // adjust translation transform according to new bounds
        let phvCurrentTransform = playerHolderView.transform
        let phvCurrentScale = phvCurrentTransform.scalePoint
        let phvCurrentTranslation = phvCurrentTransform.translationPoint
        let phvNewTranslation = CGAffineTransform(translationX: phvCurrentTranslation.x * adjustmentScale.x,
                                                  y: phvCurrentTranslation.y * adjustmentScale.y)

        let pvCurrentTransform = playerView.transform
        let pvCurrentScale = pvCurrentTransform.scalePoint
        let pvCurrentTranslation = pvCurrentTransform.translationPoint
        let pvNewTranslation = CGAffineTransform(translationX: pvCurrentTranslation.x * adjustmentScale.x,
                                                 y: pvCurrentTranslation.y * adjustmentScale.y)

        // reset transform before re-bounds
        playerHolderView.transform = .identity
        playerView.transform = .identity
        
        // re-bounds
        reBounds(to: newSize, center: newCenter)

        // apply transform for new bounds
        playerHolderView.transform = phvNewTranslation
            .scaledBy(x: phvCurrentScale.x, y: phvCurrentScale.y)

        playerView.transform = pvNewTranslation
            .scaledBy(x: pvCurrentScale.x, y: pvCurrentScale.y)
    }
    
    // call the method to add player to view hierarchy
    @discardableResult
    func setPlayerView(_ view: UIView) -> Bool {
        if view.subviews.count == 0 {
            playerView.addSubview(view)
            return true
        }
        return false
    }
    
    func makeBackgoundImage() {
        if self.playerHolderView.image == nil {
            let image = playerView.takeSnapshot()
            playerHolderView.image = image
        }
    }
    
    // call the method to get zoom info related to camera resolution
    func zoomInfo() -> ZoomInfo {
        guard isZoomingEnabled else {
            return ZoomInfo(playerTransform: .identity,
                                 cameraTransform: .identity,
                                 playerResolution: CGSize.zero)
        }
        let bounds = cropView.bounds
        let currentScaleX = bounds.width / playerHolderView.transformedSize.width
        let currentScaleY = bounds.height / playerHolderView.transformedSize.height
        var deltaPoint = CGPoint(x: ((playerHolderView.transformedSize.width - bounds.width) / 2),
                                 y: ((playerHolderView.transformedSize.height - bounds.height) / 2))
        deltaPoint.x += playerHolderView.transformedOrigin.x
        deltaPoint.y += playerHolderView.transformedOrigin.y
        
        let playerTransform = CGAffineTransform(scaleX: currentScaleX, y: currentScaleY)
            .translatedBy(x: -deltaPoint.x, y: -deltaPoint.y)

        let cameraTransform = CGAffineTransform(scaleX: currentScaleX, y: currentScaleY)
            .translatedBy(x: abs(playerHolderView.transformedOrigin.x),
                          y: abs(playerHolderView.transformedOrigin.y))

        return ZoomInfo(playerTransform: playerTransform,
                             cameraTransform: cameraTransform,
                             playerResolution: bounds.size)
    }
    
    func updatePlayerView(zoomInfo: ZoomInfo) {
        playerView.layer.borderWidth = cameraCropBorderWidth
        // update player if player resolution was changed
        let oldPlayerResolution = zoomInfo.playerResolution
        let currentPlayerResolution = cropView.bounds.size
        var playerTransform = zoomInfo.playerTransform
        if !oldPlayerResolution.equalTo(currentPlayerResolution) {
            // calculate adjustment scale
            let adjustmentScale = CGPoint(x: currentPlayerResolution.width / oldPlayerResolution.width,
                                          y: currentPlayerResolution.height / oldPlayerResolution.height)
            
            let pvCurrentTransform = playerTransform
            let pvCurrentScale = pvCurrentTransform.scalePoint
            let pvCurrentTranslation = pvCurrentTransform.translationPoint
            let pvNewTranslation = CGAffineTransform(translationX: pvCurrentTranslation.x * adjustmentScale.x,
                                                     y: pvCurrentTranslation.y * adjustmentScale.y)
            
            playerTransform = pvNewTranslation
                .scaledBy(x: pvCurrentScale.x, y: pvCurrentScale.y)
        }
        // apply transform
        UIView.animate(withDuration: 0.1) {
            self.playerView.transform = playerTransform
        }
    }
    
    func updatePlayerView(ratio: CGFloat) {
        zoomConfig.videoRatio = ratio
        NSLayoutConstraint.deactivate([frameTrackerViewWidthConstraint])
        frameTrackerViewWidthConstraint = frameTrackerView.heightAnchor.constraint(equalTo: frameTrackerView.widthAnchor,
                                                                                   multiplier: zoomConfig.videoRatio)
        NSLayoutConstraint.activate([frameTrackerViewWidthConstraint])
        frameTrackerView.trackingFrame = CGRect(origin: CGPoint.zero,
                                                size: CGSize(width: ZoomTrackerViewConfig.witdth,
                                                             height: ZoomTrackerViewConfig.witdth * zoomConfig.videoRatio))
        contentView.setNeedsLayout()
    }
        
    // reset views bounds to initial state
    func reset() {
        playerView.layer.borderWidth = 0
        playerHolderView.image = nil
        frameTrackerView.reset()
        playerView.transform = .identity
        playerHolderView.transform = .identity
    }
    
    // take video snapshot
    func videoThumbnail() -> UIImage? {
        return playerView.takeSnapshot()
    }
    
    // take snapshot of visible video frame
    func viewSnapshot() -> UIImage? {
        return cropView.takeSnapshot()
    }
    
    func playerResolution() -> CGSize {
        return cropView.bounds.size
    }
    
    var isZoomingEnabled: Bool = false {
        didSet {
            if isZoomingEnabled {
                contentView.addGestureRecognizer(pinchGesture)
                contentView.addGestureRecognizer(panGesture)
            } else {
                contentView.removeGestureRecognizer(pinchGesture)
                contentView.removeGestureRecognizer(panGesture)
            }
        }
    }

    var isTrackerHidden: Bool = true {
        didSet {
            if isTrackerHidden {
                hideTracker()
            } else {
                showTracker()
            }
        }
    }
    
    var hideTrackerOnIdle: Bool = true
        
    var currentZoom: CGFloat {
        return playerHolderView.transform.scalePoint.x
    }
    
    var clipToCrop: Bool = true {
        didSet {
            cropView.clipsToBounds = clipToCrop
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard isZoomingEnabled else {
            return false
        }
        
        let currentScale = playerHolderView.transform.scalePoint
        guard currentScale.x != zoomConfig.minZoom else {
            return false
        }
        
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        
        let offset = panGesture.translation(in: playerHolderView)
        // validate offset against bounds of parent view
        let transform = CGAffineTransform(scaleX: currentScale.x, y: currentScale.y)
        let scaledOffset = offset.applying(transform)
        let pointToValidate = playerHolderView.transformedOrigin
            .applying(CGAffineTransform(translationX: scaledOffset.x, y: scaledOffset.y))
        let validOffset = validatePointToBounds(childPoint: pointToValidate,
                                                childSize: playerHolderView.transformedSize,
                                                parentSize: cropView.bounds.size)
        // suppress pan gesture recognition if reaching edges by Y
        if validOffset.y != 0 {
            return false
        }
        
        return true
    }

    // MARK: Notification & events handlers

    @objc private func pinchHandler(sender: UIPinchGestureRecognizer) {
        func updatePositionAfterScaling() {
            // update position to keep scalled view in bounds of parent
            let validOffset = validatePointToBounds(childPoint: playerHolderView.transformedOrigin,
                                                    childSize: playerHolderView.transformedSize,
                                                    parentSize: cropView.bounds.size)
            playerHolderView.transform = playerHolderView.transform.translatedBy(x: validOffset.x, y: validOffset.y)
        }
        guard isZoomingEnabled else {
            return
        }
        if sender.state == .began {
            handleRectStartChange()
        } else {
            let currentScale = playerHolderView.transform.scalePoint
            // calculate scale according to scale velocity
            var scale = zoomConfig.minZoom + ((sender.scale - zoomConfig.minZoom) * zoomConfig.scaleVelocity)
            sender.scale = 1.0
            
            let maxZoom = zoomConfig.maxZoom
            let newScale = currentScale.x * scale
            if newScale > maxZoom ||
                newScale < zoomConfig.minZoom {
                return
            }
            
            let isScalingDown = currentScale.x > newScale
            // to improve user experience reset zoom to default value
            // when it reaches min value + defined precision
            if newScale.round(to: 1) <= (zoomConfig.minZoom + zoomConfig.scalePrecision) && isScalingDown {
                scale = cropView.bounds.width / playerHolderView.transformedSize.width
            }
            
            // scale and transform around pinch center
            let bounds = playerHolderView.bounds
            var pinchCenter = sender.location(in: playerHolderView)
            pinchCenter.x -= bounds.midX
            pinchCenter.y -= bounds.midY
            let transform = playerHolderView.transform
                .translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: scale, y: scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            playerHolderView.transform = transform

            updatePositionAfterScaling()

            handleRectDoChange()
            
            if sender.state != .changed {
                updatePositionAfterScaling()

                handleRectDidChange()
            }
        }
    }
    
    @objc private func panHandler(sender: UIPanGestureRecognizer) {
        guard isZoomingEnabled else {
            return
        }
        var offset = sender.translation(in: playerHolderView)
        sender.setTranslation(CGPoint.zero, in: playerHolderView)
        if sender.state == .began {
            handleRectStartChange()
        } else {
            let currentScale = playerHolderView.transform.scalePoint
            if currentScale.x == zoomConfig.minZoom {
                return
            }

            // validate offset against bounds of parent view
            let transform = CGAffineTransform(scaleX: currentScale.x, y: currentScale.y)
            let scaledOffset = offset.applying(transform)
            let pointToValidate = playerHolderView.transformedOrigin
                .applying(CGAffineTransform(translationX: scaledOffset.x, y: scaledOffset.y))
            let validOffset = validatePointToBounds(childPoint: pointToValidate,
                                                    childSize: playerHolderView.transformedSize,
                                                    parentSize: cropView.bounds.size)
            if !validOffset.equalTo(CGPoint.zero) {
                let deltaOffset = validOffset.applying(transform.inverted())
                offset.x += deltaOffset.x
                offset.y += deltaOffset.y
            }
            
            // move view on offset value
            playerHolderView.transform = playerHolderView.transform
                .translatedBy(x: offset.x, y: offset.y)

            handleRectDoChange()

            if sender.state != .changed {
                handleRectDidChange()
            }
        }
    }
    
    // MARK: Helpers
            
    private func validateSizeToPlayerRatio(of size: CGSize) -> CGSize {
        let viewRatio = size.height / size.width
        if viewRatio > zoomConfig.videoRatio {
            return CGSize(width: size.width, height: size.width * zoomConfig.videoRatio)
        } else {
            return CGSize(width: size.height / zoomConfig.videoRatio, height: size.height)
        }
    }
    
    private func validatePointToBounds(childPoint: CGPoint, childSize: CGSize, parentSize: CGSize) -> CGPoint {
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        if childPoint.x > 0 {
            xOffset = -childPoint.x
        }
        if childPoint.y > 0 {
            yOffset = -childPoint.y
        }
        let childXPointBR = childPoint.x + childSize.width
        if childPoint.x + childSize.width < parentSize.width {
            xOffset = parentSize.width - childXPointBR
        }
        let childYPointBR = childPoint.y + childSize.height
        if childYPointBR < parentSize.height {
            yOffset = parentSize.height - childYPointBR
        }
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    private func showTracker() {
        workItemToHideTracker?.cancel()
        
        UIView.animate(withDuration: animationDuration) {
            self.frameTrackerView.isHidden = false
        }
    }

    private func hideTracker() {
        UIView.animate(withDuration: animationDuration) {
            self.frameTrackerView.isHidden = true
        }
    }

    private func handleRectStartChange() {
        showTracker()
        
        delegate?.startPlayerRectChang(source: self)
    }
    
    private func handleRectDoChange() {
        let trackerViewWidth = cropView.bounds.width * frameTrackerView.frame.width / playerHolderView.transformedSize.width
        let trackerViewHeight = cropView.bounds.height * frameTrackerView.frame.height / playerHolderView.transformedSize.height
        
        let trackerViewX = abs(playerHolderView.transformedOrigin.x) * frameTrackerView.frame.width / playerHolderView.transformedSize.width

        let trackerViewY = abs(playerHolderView.transformedOrigin.y) * frameTrackerView.frame.height / playerHolderView.transformedSize.height

        frameTrackerView.trackingFrame = CGRect(origin: CGPoint(x: trackerViewX, y: trackerViewY),
                                                size: CGSize(width: trackerViewWidth, height: trackerViewHeight))
    }

    private func handleRectDidChange() {
        handleRectDoChange()

        delegate?.stopPlayerRectChang(source: self)

        if hideTrackerOnIdle {
            workItemToHideTracker = DispatchWorkItem {
                guard !(self.workItemToHideTracker?.isCancelled ?? true) else {
                    return
                }
                
                self.hideTracker()
            }

            if let workItem = workItemToHideTracker {
                DispatchQueue.main.asyncAfter(deadline: .now() + requestTimeout, execute: workItem)
            }
        }
    }
    
    private func reBounds(to size: CGSize, center: CGPoint) {
        cropView.bounds.size = size
        cropView.center = center
        playerHolderView.bounds = cropView.bounds
        playerHolderView.center = CGPoint(x: cropView.bounds.width / 2,
                                          y: cropView.bounds.height / 2)
        playerView.bounds = playerHolderView.bounds
        playerView.center = CGPoint(x: playerHolderView.bounds.width / 2,
                                    y: playerHolderView.bounds.height / 2)
    }

}
