//
//  File.swift
//  
//
//  Created by Ajay Ghodadra on 21/09/23.
//

import Foundation

@propertyWrapper
public class Atomic<T> {
    public var wrappedValue: T {
        get {
            var currentValue: T!
            mutate { currentValue = $0 }
            return currentValue
        }

        set {
            mutate { $0 = newValue }
        }
    }

    private let lock = NSRecursiveLock()
    private var _wrappedValue: T

    /// Update the value safely.
    /// - Parameter changes: a block with changes. It should return a new value.
    public func mutate(_ changes: (_ value: inout T) -> Void) {
        lock.lock()
        changes(&_wrappedValue)
        lock.unlock()
    }

    /// Update the value safely.
    /// - Parameter changes: a block with changes. It should return a new value.
    public func callAsFunction(_ changes: (_ value: inout T) -> Void) {
        mutate(changes)
    }

    public init(wrappedValue: T) {
        _wrappedValue = wrappedValue
    }
}

public extension Atomic where T: Equatable {
    /// Updates the value to `new` if the current value is `old`
    /// if the swap happens true is returned
    func compareAndSwap(old: T, new: T) -> Bool {
        lock.lock()
        defer {
            lock.unlock()
        }

        if _wrappedValue == old {
            _wrappedValue = new
            return true
        }
        return false
    }
}
