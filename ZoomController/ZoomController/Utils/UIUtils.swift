//
//  UIUtils.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/28/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

func sizeConstrained(toWidth: CGFloat, label: UILabel) -> CGSize {
    let aText = NSMutableAttributedString(attributedString: label.attributedText!)
    
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paragraphStyle.lineBreakMode = .byWordWrapping
    aText.addAttributes([NSAttributedString.Key.font: label.font], range: NSMakeRange(0, (aText.length)))
    aText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, (aText.length)))
    
    let rect = aText.boundingRect(with: CGSize(width: toWidth, height:CGFloat(Int.max)),
                                  options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
    
    return rect.size
}

func sizeConstrained(toWidth: CGFloat, forAttributedString: NSAttributedString) -> CGSize {
    let aText = NSMutableAttributedString(attributedString: forAttributedString)
    
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paragraphStyle.lineBreakMode = .byWordWrapping
    aText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, (aText.length)))
    
    let rect = aText.boundingRect(with: CGSize(width: toWidth, height:CGFloat(Int.max)),
                                  options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
    
    return rect.size
}

func sizeConstrained(toHeight: CGFloat, label: UILabel) -> CGSize {
    let aText: NSMutableAttributedString = NSMutableAttributedString(attributedString: label.attributedText!)
    
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paragraphStyle.lineBreakMode = .byWordWrapping
    aText.addAttributes([NSAttributedString.Key.font: label.font], range: NSMakeRange(0, (aText.length)))
    aText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, (aText.length)))
    
    let rect = aText.boundingRect(with: CGSize(width: CGFloat(Int.max), height:toHeight),
                                  options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
    
    return rect.size
}

func sizeConstrained(toHeight: CGFloat, forAttributedString: NSAttributedString) -> CGSize {
    let rect = forAttributedString.boundingRect(with: CGSize(width: CGFloat(Int.max), height:toHeight),
                                                options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
    
    return rect.size
}

func sizeOfAttributedStringForLabel(_ label: UILabel) -> CGSize {
    if let aText = label.attributedText {
        return sizeOfAttributedString(text: aText, font: label.font)
    } else if let text = label.text {
        return sizeOfString(text: text, font: label.font)
    }
    return CGSize.zero
}

func sizeOfString(text: String, font: UIFont) -> CGSize {
    let aText = NSMutableAttributedString(string: text)
    aText.addAttributes([NSAttributedString.Key.font: font], range: NSMakeRange(0, aText.length))
    return aText.size()
}

func sizeOfString(lable: UILabel) -> CGSize {
    guard let text = lable.text else {
        return CGSize.zero
    }
    return sizeOfString(text: text, font: lable.font)
}

func sizeOfAttributedString(text: NSAttributedString, font: UIFont) -> CGSize {
    let aText = NSMutableAttributedString(attributedString: text)
    aText.addAttributes([NSAttributedString.Key.font: font], range: NSMakeRange(0, aText.length))
    return aText.size()
}

func timeFormater(_ format: String, tm: TimeInterval) -> String {
    var ms = Int(tm * 1000)
    let s = (ms / 1000) % 60
    let m = ((ms / 1000) / 60) % 60
    let h = ((ms / 1000) / 3600)
    ms = ms % 1000
    
    var value = format
    value = value.replacingOccurrences(of: "hh", with: String(format: "%0.2d", h))
    value = value.replacingOccurrences(of: "mm", with: String(format: "%0.2d", m))
    value = value.replacingOccurrences(of: "sss", with: String(format: "%0.2d", ms))
    value = value.replacingOccurrences(of: "ss", with: String(format: "%0.2d", s))
    return value
}
