//
//  NSLayoutConstraint.swift
//  
//
//  Created by Ilya Senchukov on 08.10.2021.
//

import UIKit

infix operator =>: MultiplicationPrecedence
public func =><T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    lhs.constraint(equalTo: rhs)
}

infix operator <=: MultiplicationPrecedence
public func <= <T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualTo: rhs)
}

public func <=(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualToConstant: rhs)
}

infix operator >=: MultiplicationPrecedence
public func >= <T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualTo: rhs)
}

public func >=(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualToConstant: rhs)
}

public func +(lhs: NSLayoutConstraint, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constant = rhs
    return lhs
}

public func -(lhs: NSLayoutConstraint, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constant = -rhs
    return lhs
}

public func ==(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(equalToConstant: rhs)
}

public func ==(lhs: inout NSLayoutConstraint, rhs: CGFloat) {
    lhs.constant = rhs
}
