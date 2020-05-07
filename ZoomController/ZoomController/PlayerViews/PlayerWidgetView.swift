//
//  PlayerWidgetView.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/27/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

protocol PlayerWidgetViewProtocol {
    var isBorder: Bool { get set }
    var isShadow: Bool { get set }
    
    var captionAttributedText: NSAttributedString? { get set }
    var descriptionAttributedText: NSAttributedString? { get set }
    var videoContentSize: CGSize { get set }
    var videoContentRect: CGRect { get }
    
    func addPlayerView(_ playerView: UIView)
}

class PlayerWidgetView: UIView, PlayerWidgetViewProtocol {
    
    // MARK: Fields

    private let contentMarging = ThemeManager.shared.currentTheme.itemInsets
    private let cornerRadius = ThemeManager.shared.currentTheme.cornerRadius
    
    private let contentView = UIImageView()
    
    private let title = UILabel()
    private let desc = UILabel()
    
    private var layoutConstraints = [NSLayoutConstraint]()
    private var holderViewLayoutConstraints = [NSLayoutConstraint]()

    // MARK: Initializer/Deinitializer
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initializeUI()
    }
    
    deinit {}
    
    // MARK: View life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()

        makeLayoutConstraints()
    }
    
    // MARK: PlayerViewProtocol
    
    var isBorder: Bool = false {
        didSet {
            if(isBorder) {
                layer.borderWidth = 1
            } else {
                layer.borderWidth = 0
            }
        }
    }
    
    var isShadow: Bool = false {
        didSet {
            if (isShadow) {
                layer.shadowOpacity = 0.6
                layer.shadowRadius = 2
            } else {
                layer.shadowOpacity = 0
                layer.shadowRadius = 0
            }
        }
    }
    
    var captionAttributedText: NSAttributedString? {
        get {
            return title.attributedText
        }
        set (v) {
            title.attributedText = v
            setNeedsLayout()
        }
    }
        
    var descriptionAttributedText: NSAttributedString? {
        get {
            return desc.attributedText
        }
        set (v) {
            desc.attributedText = v
            setNeedsLayout()
        }
    }
    
    var videoContentSize: CGSize = CGSize.zero {
        didSet {
            makeLayoutConstraints()
            setNeedsLayout()
        }
    }
    
    var videoContentRect: CGRect {
        return CGRect(origin: contentView.center, size: videoContentSize)
    }
    
    func addPlayerView(_ playerView: UIView) {
        guard (subviews.first { $0 == playerView }) == nil else {
            return
        }
        
        contentView.isUserInteractionEnabled = true
        contentView.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        holderViewLayoutConstraints.append(contentsOf: [
            playerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            playerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            playerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            playerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
        layoutConstraints.append(contentsOf: holderViewLayoutConstraints)
        
        setNeedsLayout()
    }
    
    // MARK: Helpers
    
    private func initializeUI() {
        contentView.contentMode = .scaleAspectFit
        contentView.backgroundColor = .black
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        title.textColor = .label
        title.lineBreakMode = .byTruncatingTail
        title.numberOfLines = 2
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: 14)
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)

        desc.bounds = CGRect.zero
        desc.textColor = .secondaryLabel
        desc.lineBreakMode = .byTruncatingTail
        desc.numberOfLines = 0
        desc.textAlignment = .left
        desc.font = UIFont.systemFont(ofSize: 12)
        desc.translatesAutoresizingMaskIntoConstraints = false
        addSubview(desc)

        backgroundColor = .white

        layer.cornerRadius = cornerRadius
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0
        layer.masksToBounds = true
    }
    
    private func makeLayoutConstraints() {
        NSLayoutConstraint.deactivate(layoutConstraints)
        
        layoutConstraints.removeAll()
        layoutConstraints.append(contentsOf: [
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            contentView.heightAnchor.constraint(equalToConstant: videoContentSize.height)
        ])
        
        let infoContentHeight = bounds.height - videoContentSize.height
        layoutConstraints.append(contentsOf: [
            title.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: contentMarging),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentMarging),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentMarging),
            title.heightAnchor.constraint(equalToConstant: infoContentHeight * 1 / 3)
        ])

        layoutConstraints.append(contentsOf: [
            desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: contentMarging),
            desc.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentMarging),
            desc.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentMarging),
            desc.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentMarging)
        ])
        layoutConstraints.append(contentsOf: holderViewLayoutConstraints)

        NSLayoutConstraint.activate(layoutConstraints)
    }
    
}
