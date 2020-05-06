//
//  Eventer.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/28/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import Foundation

class EventArgs: NSObject {
    override init() {
        super.init()
    }
}

public class Eventer {
    
    // MARK: Fields
    
    private var targets = [Int: Weak<AnyObject>]()
    private var actions = [Int: Set<Selector>]()
    private let lock = Lock<NSRecursiveLock>()
    
    // MARK: Initializers/Deinitializer
    
    deinit {
        removeAll()
    }
    
    // MARK: Public methods
    
    func add(target: AnyObject, action: Selector) {
        lock.synchronize {
            if target.responds(to: action) {
                if targets[target.hash] == nil {
                    targets[target.hash] = Weak(object: target)
                    actions[target.hash] = Set()
                    actions[target.hash]?.insert(action)
                } else {
                    if !(actions[target.hash]?.contains(action) ?? false) {
                        actions[target.hash]?.insert(action)
                    }
                }
            }
        }
    }
    
    func remove(target: AnyObject) {
        lock.synchronize {
            if let hash = target.hash {
                if let idx1 = targets.index(forKey: hash) {
                    targets.remove(at: idx1)
                }
                
                if let idx2 = actions.index(forKey: hash) {
                    actions.remove(at: idx2)
                }
            }
        }
    }
    
    func remove(target: AnyObject, action: Selector) {
        lock.synchronize {
            if let hash = target.hash,
                let idx = targets.index(forKey: hash) {
                actions[hash]?.remove(action)
                if actions[hash]?.count == 0 {
                    targets.remove(at: idx)
                    if let idx2 = actions.index(forKey: hash) {
                        actions.remove(at: idx2)
                    }
                }
            }
        }
    }
    
    func removeAll() {
        lock.synchronize {
            actions.removeAll()
            targets.removeAll()
        }
    }
    
    func invoke(source: AnyObject, eventArgs: EventArgs?) {
        lock.synchronize {
            for (hash, target) in targets {
                if let object = target.object,
                    let actions = actions[hash] {
                    for action in actions where object.responds(to: action) {
                        if eventArgs != nil {
                            _ = object.perform(action, with: source, with: eventArgs)
                        } else {
                            _ = object.perform(action, with: source)
                        }
                    }
                }
            }
        }
    }
    
    func invokeSatisfied(to predicate: (AnyObject) -> Bool, source: AnyObject, eventArgs: EventArgs?) {
        lock.synchronize {
            for (hash, target) in targets {
                if let object = target.object,
                    predicate(object),
                    let actions = actions[hash] {
                    for action in actions where object.responds(to: action) {
                        if eventArgs != nil {
                            _ = object.perform(action, with: source, with: eventArgs)
                        } else {
                            _ = object.perform(action, with: source)
                        }
                    }
                }
            }
        }
    }
    
}
