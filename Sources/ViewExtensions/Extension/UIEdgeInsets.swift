//
//  UIEdgeInsets.swift
//  
//
//  Created by Ilya Senchukov on 07.11.2021.
//

import UIKit

public extension UIEdgeInsets {

    static func vertical(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: value, left: 0, bottom: value, right: 0)
    }

    static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: value, bottom: 0, right: value)
    }

    static func left(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: value, bottom: 0, right: 0)
    }

    static func right(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: 0, bottom: 0, right: value)
    }

    static func top(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: value, left: 0, bottom: 0, right: 0)
    }

    static func bottom(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: 0, bottom: value, right: 0)
    }
}
