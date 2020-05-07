//
//  ZoomModel.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/24/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

struct ZoomInfo {
    let playerTransform: CGAffineTransform
    let cameraTransform: CGAffineTransform
    let playerResolution: CGSize
    
    init(playerTransform: CGAffineTransform,
         cameraTransform: CGAffineTransform,
         playerResolution: CGSize) {
        self.playerTransform = playerTransform
        self.cameraTransform = cameraTransform
        self.playerResolution = playerResolution
    }

    // copy constructor
    init(info: ZoomInfo) {
        self.playerTransform = info.playerTransform
        self.cameraTransform = info.cameraTransform
        self.playerResolution = info.playerResolution
    }
}

protocol ZoomModelDelegate: class {
    func didSendFrame(source: ZoomModelProtocol)
    func didReceiveFrame(source: ZoomModelProtocol, zoomInfo: ZoomInfo)
}

protocol ZoomModelProtocol: class {
    init(delegate: ZoomModelDelegate)
    
    var sourceResolution: CGSize { get }
    var maxZoom: CGFloat { get }
    
    func sendZoomInfoAfterDelay(zoomInfo: ZoomInfo)
    func sendZoomInfo(zoomInfo: ZoomInfo) -> Bool
    func reset()
}

private let requestTimeout: Double = 3
    
class ZoomModel: ZoomModelProtocol {
    
    // MARK: Fields
    
    private var minZoomResolution = CGSize(width: 4096, height: 4096 * 9 / 16)

    private var requestWorkItem: DispatchWorkItem?
    private weak var delegate: ZoomModelDelegate?
    
    // MARK: Initializers/Deinitializer
    
    required init(delegate: ZoomModelDelegate) {
        self.delegate = delegate
    }
    
    deinit {
        // default
    }
    
    // MARK: ZoomModelProtocol
    
    private(set) var sourceResolution = CGSize(width: 640, height: 640 * 9 / 16)

    var maxZoom: CGFloat {
        return Swift.min(sourceResolution.height / minZoomResolution.height,
                         sourceResolution.width / minZoomResolution.width)
    }
    
    func sendZoomInfoAfterDelay(zoomInfo: ZoomInfo) {
        requestWorkItem?.cancel()
        requestWorkItem = DispatchWorkItem {
            guard !(self.requestWorkItem?.isCancelled ?? true) else {
                return
            }

            self.sendZoomInfo(zoomInfo: zoomInfo)
        }

        if let workItem = requestWorkItem {
            DispatchQueue.global().asyncAfter(deadline: .now() + requestTimeout, execute: workItem)
        }
    }

    @discardableResult
    func sendZoomInfo(zoomInfo: ZoomInfo) -> Bool {
        DispatchQueue.main.async {
            self.delegate?.didSendFrame(source: self)
        }
        
        var frame = calculateSourceRect(zoomInfo: zoomInfo)
        frame = validateOutgoingRect(frame, zoomInfo: zoomInfo)
        
        // code to send new rect and wait for result
        // handleDidRectApply(rect: <new rect here>, zoomInfo: zoomInfo)
        
        return true
    }
    
    func reset() {
        requestWorkItem?.cancel()
        resetZoom()
    }
    
    // MARK: Helpers

    private func resetZoom() {
        // code to reset zoom on sorce side can be here
    }

    private func handleDidRectApply(rect: CGRect, zoomInfo: ZoomInfo) {
        let newZoomInfo = validateIncomingRect(rect, zoomInfo: zoomInfo)
        delegate?.didReceiveFrame(source: self, zoomInfo: ZoomInfo(info: newZoomInfo))
    }

    // calculate outgoing rect according to client offset and scale values
    private func calculateSourceRect(zoomInfo: ZoomInfo) -> CGRect {
        // calculate adjustment scale
        let adjustmentScale = CGPoint(x: sourceResolution.width / zoomInfo.playerResolution.width,
                                      y: sourceResolution.height / zoomInfo.playerResolution.height)

        // adjust translation transform according to new bounds
        let cameraTransform = zoomInfo.cameraTransform
        let cameraScale = cameraTransform.scalePoint
        let cameraTranslation = cameraTransform.translationPoint
        let cameraNewTranslation = CGAffineTransform(translationX: cameraTranslation.x * adjustmentScale.x,
                                                     y: cameraTranslation.y * adjustmentScale.y)

        let cameraNewTransform = cameraNewTranslation
            .scaledBy(x: cameraScale.x, y: cameraScale.y)
        var frame = CGRect(origin: CGPoint.zero, size: sourceResolution)
        frame = frame.applying(cameraNewTransform)
        frame = round(rect: frame)

        return frame
    }

    // needs to validate client rect against minimum allowed resolution by FW
    private func validateOutgoingRect(_ rect: CGRect, zoomInfo: ZoomInfo) -> CGRect {
        var rect = rect
        if rect.width < minZoomResolution.width ||
            rect.height < minZoomResolution.height {
            
            let adjustmentScale = CGPoint(x: rect.width / minZoomResolution.width,
                                    y: rect.height / minZoomResolution.height)
            
            let deltaPoint = CGPoint(x: (rect.width - minZoomResolution.width) / 2,
                                     y: (rect.height - minZoomResolution.height) / 2)
            
            // adjust scaled frame by X to conform camera resolution
            var adjustedX = rect.minX + deltaPoint.x
            adjustedX = adjustedX < 0 ? 0 : adjustedX
            let adjustedWidth = rect.width / adjustmentScale.x
            let adjustedRightX = adjustedWidth + adjustedX
            adjustedX = adjustedRightX > sourceResolution.width ?
                (adjustedX - (adjustedRightX - sourceResolution.width)) : adjustedX
            
            // adjust scaled frame by Y to conform camera resolution
            var adjustedY = rect.minY + deltaPoint.y
            adjustedY = adjustedY < 0 ? 0 : adjustedY
            let adjustedHeight = rect.height / adjustmentScale.y
            let adjustedBottomY = adjustedHeight + adjustedY
            adjustedY = adjustedBottomY > sourceResolution.height ?
                (adjustedY - (adjustedBottomY - sourceResolution.height)) : adjustedY

            rect = CGRect(x: adjustedX, y: adjustedY,
                          width: adjustedWidth, height: adjustedHeight)
        }
        
        return rect
    }

    // needs to validate incoming rect since FW returns not exact the same value what client sends
    private func validateIncomingRect(_ rect: CGRect, zoomInfo: ZoomInfo) -> ZoomInfo {
        // calculate scale of player resolution to camera
        let adjustmentScale = CGPoint(x: zoomInfo.playerResolution.width / sourceResolution.width,
                                      y: zoomInfo.playerResolution.height / sourceResolution.height)

        let playerTransform = zoomInfo.playerTransform
        var playerTranslation = playerTransform.translationPoint

        // current scale, since it could be changed during validation of outgoing frame
        let playerScale = CGPoint(x: rect.width / sourceResolution.width,
                              y: rect.height / sourceResolution.height)
        
        // get origin and size according to adjustment scale
        let adjustedPoint = CGPoint(x: rect.minX * adjustmentScale.x,
                                    y: rect.minY * adjustmentScale.y)

        let adjustedSize = CGSize(width: rect.width * adjustmentScale.x,
                                  height: rect.height * adjustmentScale.y)
        
        // get x, y offeset in new coordinates
        playerTranslation = CGPoint(x: ((adjustedSize.width - zoomInfo.playerResolution.width) / 2),
                                 y: ((adjustedSize.height - zoomInfo.playerResolution.height) / 2))
        
        playerTranslation.x += adjustedPoint.x
        playerTranslation.y += adjustedPoint.y
        
        let playerNewTranslation = CGAffineTransform(translationX: playerTranslation.x,
                                                     y: playerTranslation.y)

        let playerNewTransform = playerNewTranslation
            .scaledBy(x: playerScale.x, y: playerScale.y)

        return ZoomInfo(playerTransform: playerNewTransform,
                             cameraTransform: zoomInfo.cameraTransform,
                             playerResolution: zoomInfo.playerResolution)
    }

    private func max(_ size1: CGSize, _ size2: CGSize) -> CGSize {
        return size1.width > size2.width ? size1 : size2
    }

    private func min(_ size1: CGSize, _ size2: CGSize) -> CGSize {
        return size1.width < size2.width ? size1 : size2
    }
    
    private func round(rect: CGRect) -> CGRect {
        return CGRect(x: rect.origin.x.rounded(),
                      y: rect.origin.y.rounded(),
                      width: rect.width.rounded(),
                      height: rect.height.rounded())
    }

}
