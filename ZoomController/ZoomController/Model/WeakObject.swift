//
//  WeakObject.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/28/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import Foundation

class Weak<T: AnyObject>: Equatable, Hashable {
    weak var object: T?
    init(object: T) {
        self.object = object
    }
    
    func hash(into hasher: inout Hasher) {
        if let object = self.object {
            return Unmanaged.passUnretained(object).toOpaque().hash(into: &hasher)
        }
    }
}

func == <T> (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

func == <T> (lhs: Weak<T>, rhs: T) -> Bool {
    return lhs.object === rhs
}

func == <T> (lhs: T, rhs: Weak<T>) -> Bool {
    return lhs === rhs.object
}
