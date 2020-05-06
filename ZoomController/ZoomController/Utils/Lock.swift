//
//  Lock.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/28/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import Foundation

class Lock<T: NSLocking> where T: NSObject {
    
    private let lock = T()
    
    @discardableResult func synchronize<U>(block: () -> U) -> U {
        var result: U
        lock.lock()
        defer {
            lock.unlock()
        }
        result = block()
        return result
    }
    
}
