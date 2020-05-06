//
//  Theme.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/28/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

protocol ProgressTheme {
    var progressHeight: CGFloat { get }
}

protocol Theme {
    var backgroundGradient: CAGradientLayer { get }

    var sysBackgroundColor: UIColor { get }
    var sysBorderColor: UIColor { get }

    var sysLabelColor: UIColor { get }
    var sysLabelLightColor: UIColor { get }
    var sysDescColor: UIColor { get }
    var sysTintColor: UIColor { get }

    var sysDisabledColor: UIColor { get }

    var sysRed: UIColor { get }
    var sysOrange: UIColor { get }
    var sysYellow: UIColor { get }
    var sysGreen: UIColor { get }
    var sysTealBlue: UIColor { get }
    var sysBlue: UIColor { get }
    var sysPurple: UIColor { get }
    var sysPink: UIColor { get }
    var sysGrey: UIColor { get }
    var sysLightGrey: UIColor { get }
    var sysDarkGreen: UIColor { get }

    var customDarkBlue: UIColor { get }
    var customDarkGrey: UIColor { get }
    var customBorderColor: UIColor { get }
    var customBackgroundColor: UIColor { get }

    var actionColor: UIColor { get }
    var actionHighlightedColor: UIColor { get }


    // MARK: Boundaries

    var contentMargin: CGFloat { get }
    var contentItemSpace: CGFloat { get }
    var itemInsets: CGFloat { get }

    var cornerRadius: CGFloat { get }

    var defaultButtonHeight: CGFloat { get }
    var defaultTextEditHeight: CGFloat { get }

    // MARK: Font size

    var fontSizeBig: CGFloat { get }
    var fontSizeSmall: CGFloat { get }
    var fontSizeLabel28: CGFloat { get }
    var fontSizeLabel24: CGFloat { get }
    var fontSizeLabel22: CGFloat { get }
    var fontSizeLabel20: CGFloat { get }
    var fontSizeLabel18: CGFloat { get }
    var fontSizeLabel16: CGFloat { get }
    var fontSizeLabel14: CGFloat { get }
    var fontSizeLabel12: CGFloat { get }
    var fontSizeDescBig: CGFloat { get }
    var fontSizeDescSmall: CGFloat { get }
    
    // MARK: Animation
    
    var animationDuration01: Double { get }
    var animationDuration02: Double { get }
    var animationDuration03: Double { get }
    var animationDuration04: Double { get }
    var animationDuration05: Double { get }
    var animationDuration06: Double { get }
    var animationDuration07: Double { get }
    var animationDuration08: Double { get }
    
    // MARK: Progress
    
    var progressTheme: ProgressTheme { get }

}

struct ThemeDefault: Theme {
        
    struct ProgressThemeDefault: ProgressTheme {
        var progressHeight: CGFloat
    }
        
    // MARK: Colors
    /*
     /* RGB */ test
     $color1: rgba(0, 129, 175, 1);
     $color2: rgba(45, 199, 255, 1);
     $color3: rgba(33, 118, 255, 1);
     $color4: rgba(49, 57, 60, 1);
     $color5: rgba(208, 225, 232, 1);
     
     /* RGB */ current
     $color1: rgba(60, 55, 68, 1);
     $color2: rgba(53, 56, 173, 1);
     $color3: rgba(220, 232, 247, 1);
     $color4: rgba(237, 244, 249, 1);
     $color5: rgba(220, 228, 242, 1);
     */

    // MARK: Fields
    
    private let backgroundColorStart = UIColor.white
    private let backgroundColorMiddle = UIColor(red: 220 / 255, green: 228 / 255, blue: 242 / 255, alpha: 1.0)
    private let backgroundColorEnd = UIColor(red: 237 / 255, green: 244 / 255, blue: 249 / 255, alpha: 1.0)
    
    // MARK: Initializers/Deinitializer
    
    init() {
        customBackgroundColor = backgroundColorEnd
        actionHighlightedColor = customDarkGrey
    }

    // MARK: Properties
    
    var backgroundGradient: CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [backgroundColorStart.cgColor, backgroundColorMiddle.cgColor, backgroundColorEnd.cgColor]
        gradientLayer.locations = [0.0, 0.9, 1]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        return gradientLayer
    }

    private(set) var sysBackgroundColor: UIColor = UIColor(red: 247 / 255, green: 247 / 255, blue: 247 / 255, alpha: 1)
    private(set) var sysBorderColor: UIColor = UIColor(red: 224 / 255, green: 224 / 255, blue: 224 / 255, alpha: 1)

    private(set) var sysLabelColor = UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1)
    private(set) var sysLabelLightColor = UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1)
    private(set) var sysDescColor = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
    private(set) var sysTintColor = UIColor(red: 0.204, green: 0.624, blue: 0.847, alpha: 1)

    private(set) var sysDisabledColor = UIColor(red: 123 / 255, green: 123 / 255, blue: 123 / 255, alpha: 0.48)

    private(set) var sysRed = UIColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1)
    private(set) var sysOrange = UIColor(red: 255 / 255, green: 149 / 255, blue: 0 / 255, alpha: 1)
    private(set) var sysYellow = UIColor(red: 255 / 255, green: 204 / 255, blue: 0 / 255, alpha: 1)
    private(set) var sysGreen = UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
    private(set) var sysTealBlue = UIColor(red: 90/255, green: 200 / 255, blue: 250 / 255, alpha: 1)
    private(set) var sysBlue = UIColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1)
    private(set) var sysPurple = UIColor(red: 88 / 255, green: 86 / 255, blue: 214 / 255, alpha: 1)
    private(set) var sysPink = UIColor(red: 255 / 255, green: 45 / 255, blue: 85 / 255, alpha: 1)
    private(set) var sysGrey = UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1)
    private(set) var sysLightGrey = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
    private(set) var sysDarkGreen = UIColor(red: 0 / 255, green: 135 / 255, blue: 31 / 255, alpha: 1)

    private(set) var customDarkBlue = UIColor(red: 53 / 255, green: 56 / 255, blue: 173 / 255, alpha: 1)
    private(set) var customDarkGrey = UIColor(red: 60 / 255, green: 55 / 255, blue: 68 / 255, alpha: 1)
    private(set) var customBorderColor = UIColor(red: 147 / 255, green: 141 / 255, blue: 157 / 255, alpha: 1)
    let customBackgroundColor: UIColor

    let actionColor = UIColor(red: 147 / 255, green: 141 / 255, blue: 157 / 255, alpha: 1)
    let actionHighlightedColor: UIColor
    
    // MARK: Progress

    var progressTheme: ProgressTheme {
        return ProgressThemeDefault(progressHeight: 2)
    }

    // MARK: Animation
    
    private(set) var animationDuration08: Double = 0.8
    private(set) var animationDuration07: Double = 0.7
    private(set) var animationDuration06: Double = 0.6
    private(set) var animationDuration05: Double = 0.5
    private(set) var animationDuration04: Double = 0.4
    private(set) var animationDuration03: Double = 0.3
    private(set) var animationDuration02: Double = 0.2
    private(set) var animationDuration01: Double = 0.1

    // MARK: Boundaries/Sizes

    private(set) var contentMargin: CGFloat = 16
    private(set) var contentItemSpace: CGFloat = 10
    private(set) var itemInsets: CGFloat = 5

    private(set) var cornerRadius: CGFloat = 5

    var defaultButtonHeight: CGFloat {
        return 44
    }

    var defaultTextEditHeight: CGFloat {
        return 44
    }

    // MARK: Font size

    var fontSizeBig: CGFloat {
        return 16
    }

    var fontSizeSmall: CGFloat {
        return 14
    }

    var fontSizeLabel28: CGFloat {
        return 28
    }

    var fontSizeLabel24: CGFloat {
        return 24
    }

    var fontSizeLabel22: CGFloat {
        return 22
    }

    var fontSizeLabel20: CGFloat {
        return 20
    }

    var fontSizeLabel18: CGFloat {
        return 18
    }

    var fontSizeLabel16: CGFloat {
        return 16
    }

    var fontSizeLabel14: CGFloat {
        return 14
    }

    var fontSizeLabel12: CGFloat {
        return 12
    }

    var fontSizeDescBig: CGFloat {
        return 14
    }

    var fontSizeDescSmall: CGFloat {
        return 12
    }
}

struct ThemeManager {
    
    // MARK: Propertis
    
    var currentTheme: Theme
    
    // MARK: Initializers/Deinitializer
    
    init() {
        currentTheme = ThemeDefault()
    }
    
    // MARK: Static
    
    static let shared = ThemeManager()
}

