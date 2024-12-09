//
//  NSLayoutConstraint.swift
//  
//
//  Created by Ilya Senchukov on 08.10.2021.
//

import UIKit

// MARK: Equal

infix operator -->: MultiplicationPrecedence
@MainActor public func --> <T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    lhs.constraint(equalTo: rhs)
}

// MARK: Less than or equal

@MainActor public func <= <T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualTo: rhs)
}

@MainActor public func <=(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualToConstant: rhs)
}

// MARK: Greater than or equal

@MainActor public func >= <T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualTo: rhs)
}

@MainActor public func >=(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualToConstant: rhs)
}

// MARK: Constants

@MainActor public func +(lhs: NSLayoutConstraint, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constant = rhs
    return lhs
}

@MainActor public func -(lhs: NSLayoutConstraint, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constant = -rhs
    return lhs
}

@MainActor public func ==(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(equalToConstant: rhs)
}

@MainActor public func ==(lhs: inout NSLayoutConstraint, rhs: CGFloat) {
    lhs.constant = rhs
}
