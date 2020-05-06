//
//  GenericFormater.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/29/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import Foundation

protocol GenericFormater {
    
    // MARK: Public methods
    
    func format(value: Any) -> String
}

class TimePlayBackFormater: GenericFormater {
    
    func format(value: Any) -> String {
        return format2(value: value as! Double)
    }
    
    func format2(value: Double) -> String {
        return "\(timeFormater("hh:mm:ss", tm: TimeInterval(value)))"
    }
    
}
